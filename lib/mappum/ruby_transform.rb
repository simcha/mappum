# TODO docs
require 'set'
require 'mappum'
require 'ostruct'
require 'mappum/autoconv_catalogue'

module Mappum
  #
  # Main class handling transformation of ruby to ruby objects. 
  # This class is a base for other transformations in Mappum. 
  #
  class RubyTransform
    attr_accessor :map_catalogue
    
    def initialize(map_catalogue = nil, default_struct_class=nil)
      @map_catalogue = map_catalogue if map_catalogue.kind_of?(Mappum::Map)
      @map_catalogue ||= Mappum.catalogue(map_catalogue)
      @autoconv_map_catalogue = Mappum.catalogue("MAPPUM_AUTOCONV")
      @default_struct_class = default_struct_class
      @default_struct_class ||= Mappum::OpenStruct;
    end
    #
    # Method for transforming from object using map to "to" object.
    #
    def transform(from, map=nil, to=nil)
      
      raise RuntimeError.new("Map catalogue is empty!") if @map_catalogue.nil?
      
      map ||= @map_catalogue[from.class]
      
      raise MapMissingException.new(from) if map.nil?
      
      #to ||= map.to.clazz.new unless map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
      
      all_nils = true
      map.maps.each do |sm|
        from_value, to_value = nil, nil
        
        if sm.from.respond_to?(:name)
           from_value = get(from, sm.from.name) 
        else
           from_value = sm.from.value
        end
        submaps = sm.maps
        if sm.maps.empty?
          unless sm.submap_alias.nil? or sm.submap_alias.empty?
            submaps = @map_catalogue[sm.submap_alias].maps
          end
          if sm.to.respond_to?(:clazz) and sm.from.respond_to?(:clazz) and sm.from.clazz != sm.to.clazz
            sub = @map_catalogue[sm.from.clazz,sm.to.clazz]
            sub ||= @autoconv_map_catalogue[sm.from.clazz,sm.to.clazz]
            unless  sub.nil? 
             submaps = sub.maps
            else
             to_value = from_value
            end
          else
            to_value = from_value
          end
        end
        unless submaps.empty? or from_value.nil?
          if from_value.kind_of?(Array) or 
              (Module.constants.include? "ArrayJavaProxy" and from_value.kind_of?(Module.const_get(:ArrayJavaProxy)))
            sm_v = sm.clone
            if sm_v.from.is_array
              sm_v.from = sm.from.clone
              sm_v.from.is_array = false
            end
            if sm_v.to.is_array
              sm_v.to = sm.to.clone
              sm_v.to.is_array = false
            end
            sm_v.maps = submaps if sm_v.maps.empty?
            
            to_value = from_value.collect{|v| transform(v, sm_v)}
          else
            to ||= map.to.clazz.new unless map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
            to ||= @default_struct_class.new
            v_to = nil
            #array values are assigned after return
            v_to = get(to, sm.to.name) unless sm.to.is_array and not sm.from.is_array
            sm_v = sm
            if sm_v.maps.empty?
              sm_v = sm.clone
              sm_v.maps = submaps
            end
            to_value = transform(from_value, sm_v, v_to)
          end

        end
        unless sm.func.nil? or (not sm.func_on_nil? and to_value.nil?)
          to_value = sm.func.call(to_value)
        end
        unless sm.from.func.nil? or to_value.nil?
          to_value = to_value.instance_eval(sm.from.func)
        end
        unless sm.dict.nil?
          to_value = sm.dict[to_value]
        end
        if sm.to.is_array and not sm.from.is_array
          to_array = convert_from(get(to,sm.to.name),sm.from)
          to_array ||= []
          to_array << to_value
          
          if to_array.empty? and sm.strip_empty?
            to_array = nil
          end
          
          all_nils = false unless to_array.nil?

          if sm.to.name.nil?
            to = convert_to(to_array, sm.to)
          else
            to ||= map.to.clazz.new unless map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
            to ||= @default_struct_class.new
            to.send("#{sm.to.name}=", convert_to(to_array, sm.to)) unless to_array.nil?
          end
        else

          if to_value.respond_to?(:empty?) and to_value.empty? and sm.strip_empty?
            to_value = nil
          end
          
          all_nils = false unless to_value.nil?

          if sm.to.name.nil?
            to ||= to_value
          else
            to ||= map.to.clazz.new unless map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
            to ||= @default_struct_class.new 
            to.send("#{sm.to.name}=", convert_to(to_value, sm.to)) unless to_value.nil?
          end
        end
        
      end
      if all_nils and map.strip_empty?
        return nil
      end
      return to
    end
    
    protected
    
    def get(object, field)
      if field.nil?
        return object
      elsif
        begin
          return object.send(field)
        rescue NoMethodError => e
          #for open structures field will be defined later
            if object.kind_of?(@default_struct_class)
              return nil
            else
              raise e
            end
         end          
      end
    end
    def convert_to(to, field_def)
      return to
    end
    def convert_from(from, field_def)
      return from
    end
  end
  class OpenStruct < OpenStruct
    def type(*attr)
      method_missing(:type, *attr)
    end
    def id(*attr)
      method_missing(:id, *attr)
    end
  end
  class MapMissingException < RuntimeError
    attr_accessor :from
    def initialize(from, msg=nil)
      msg ||= "Map for class \"#{from.class}\" not found!"
      super(msg)
      @from = from
  end
end
end
