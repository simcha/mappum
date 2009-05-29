# TODO docs
require 'set'
require 'mappum'
require 'ostruct'

module Mappum
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
  class RubyTransform
    attr_accessor :map_catalogue
    
    def initialize(map_catalogue = nil, default_struct_class=nil)
      @map_catalogue = map_catalogue if map_catalogue.kind_of?(Mappum::Map)
      @map_catalogue ||= Mappum.catalogue(map_catalogue)
      @default_struct_class = default_struct_class
      @default_struct_class ||= Mappum::OpenStruct;
    end
    def get(object, field)
      if field.nil?
        return object
      elsif not object.kind_of?(@default_struct_class) or 
        object.respond_to?(field)
        return object.send(field)
      else
        #for open structures field will be defined later
        return nil
      end
    end
    def transform(from, map=nil, to=nil)

      map ||= @map_catalogue[from.class]
      
      raise MapMissingException.new(from) if map.nil?
      
      to ||= map.to.clazz.new unless map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)

      all_nils = true

      map.maps.each do |sm|
        to_value = nil

        from_value = get(from, sm.from.name)

        if sm.maps.empty?
          to_value = from_value
        elsif not from_value.nil?
          if from_value.instance_of?(Array)
            sm_v = sm.clone
            sm_v.from.is_array = false
            sm_v.to.is_array = false
            to_value = from_value.collect{|v| transform(v, sm_v)}
          else
            to_value = transform(from_value, sm, get(to, sm.to.name))
          end

        end
        unless sm.func.nil? or to_value.nil?
          to_value = sm.func.call(to_value)
        end
        unless sm.from.func.nil? or to_value.nil?
          to_value = to_value.instance_eval(sm.from.func)
        end
        unless sm.dict.nil?
          to_value = sm.dict[to_value]
        end

        if sm.to.is_array and not sm.from.is_array
          to_array = get(to,sm.to.name)
          to_array ||= []
          to_array << to_value
          
          if to_array.empty? and sm.strip_empty?
            to_array = nil
          end
          
          all_nils = false unless to_array.nil?

          if sm.to.name.nil?
            to = to_array
          else
            to ||= @default_struct_class.new
            to.send("#{sm.to.name}=", to_array) unless to_array.nil?
          end
        else

          if to_value.respond_to?(:empty?) and to_value.empty? and sm.strip_empty?
            to_value = nil
          end
          
          all_nils = false unless to_value.nil?
                    
          if sm.to.name.nil?
            to ||= to_value
          elsif
            to ||= @default_struct_class.new 
            to.send("#{sm.to.name}=", to_value) unless to_value.nil?
          end
        end
        
      end
      if all_nils and map.strip_empty?
        return nil
      end
      return to
    end
  end
end