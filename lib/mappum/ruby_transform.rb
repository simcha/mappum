# TODO docs
require 'set'
require 'mappum'
require 'ostruct'
require 'mappum/autoconv_catalogue'
require 'mappum/mappum_exception'

module Mappum
  #
  # Main class handling transformation of ruby to ruby objects. 
  # This class is a base for other transformations in Mappum. 
  #
  class RubyTransform
    attr_accessor :map_catalogue
    
    def initialize(map_catalogue=nil, default_struct_class=nil, force_open_struct=false)
      @map_catalogue = map_catalogue if map_catalogue.kind_of?(Mappum::Map)
      @map_catalogue ||= Mappum.catalogue(map_catalogue)
      @autoconv_map_catalogue = Mappum.catalogue("MAPPUM_AUTOCONV")
      @default_struct_class = default_struct_class
      @force_open_struct = force_open_struct
      @default_struct_class ||= Mappum::OpenStruct;
    end
    #
    # Method for transforming from object using map to "to" object.
    #
    def transform(from, map=nil, to=nil)
      begin
      raise RuntimeError.new("Map catalogue is empty!") if @map_catalogue.nil?
      
      map ||= @map_catalogue[from.class]
      
      map = @map_catalogue[map] if map.kind_of?(Symbol) or map.kind_of?(String)
      
      raise MapMissingException.new(from) if map.nil?
      
      # skip mapping on false :map_when function
      return to unless map.map_when.nil? or map.map_when.call(from)

      all_nils = true
      map.maps.each do |sm|
        begin
        from_value, to_value = nil, nil
        
        from_value = get(from, sm.from, map.from) 

        # skip to next mapping on false :map_when function
        next unless sm.map_when.nil? or sm.map_when.call(from_value)

        unless sm.func.nil? or (not sm.func_on_nil? and from_value.nil?)
          from_value = sm.func.call(from_value)
        end
        unless sm.from.func.nil? or from_value.nil?
          mappum_block = sm.from.block
            if from_value.kind_of?(Array) 
            # TODO Fix it for JavaArrays
            #or (Module.constants.include? "ArrayJavaProxy" and from_value.kind_of?(Module.const_get(:ArrayJavaProxy)))
               from_value = from_value.compact.instance_eval(sm.from.func)
            else
              from_value = from_value.instance_eval(sm.from.func)
            end
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
          #We should make some kind of test like this
          #raise "Not an array: #{sm.from.name} inspect:" + from_value.inspect if sm.from.is_array and not from_value.kind_of?(Array)
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
            if sm_v.maps.empty?
							sm_v.maps = submaps 
							sm_v.maps.each{|m| m.from.parent = sm_v.from}
							#don't add parent we need separation
							to_value = from_value.collect{|v| transform(v, sm_v)}
						else
							to_value = from_value.collect{|v| transform(add_parent(v, from), sm_v)}
						end
          else
            to ||= map.to.clazz.new unless @force_open_struct or map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
            to ||= @default_struct_class.new
            v_to = []
            #array values are assigned after return
            v_to << get(to, sm.to) unless sm.to.is_array and not sm.from.is_array
            #nless one whants to update existing to array
            if sm.to_array_take == :first
              arr_v = get(to, sm.to)
              v_to << arr_v[0]  if not arr_v.nil?
            end
            if sm.to_array_take == :all
              arr_v = get(to, sm.to)
              v_to += arr_v  if not arr_v.nil?
            end
            #array values are assigned after return
            v_to = [nil] if sm.to.is_array and not sm.from.is_array and v_to.empty?
            v_to.each do |v_t|
				sm_v = sm
				if sm_v.maps.empty?
				  sm_v = sm.clone
				  sm_v.maps = submaps
				  sm_v.maps.each{|m| m.from.parent = sm_v.from}
				  #don't add parent we need separation
				  to_value = transform(from_value, sm_v, v_t)
				else
				  to_value = transform(add_parent(from_value, from), sm_v, v_t)
				end
		    end
          end

        end
        unless sm.dict.nil?
          to_value = sm.dict[to_value]
        end
        if sm.to.is_array and not sm.from.is_array
          to_array = convert_from(get(to,sm.to),sm.from)
          to_array ||= []
          to_array << to_value unless sm.to_array_take == :first or sm.to_array_take == :all
          
          if to_array.empty? and sm.strip_empty?
            to_array = nil
          end
          
          all_nils = false unless to_array.nil?

          if sm.to.name.nil?
            to = convert_to(to_array, sm.to)
          else
            to ||= map.to.clazz.new unless @force_open_struct or map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
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
            to ||= map.to.clazz.new unless @force_open_struct or map.to.clazz.nil? or map.to.clazz.kind_of?(Symbol)
            to ||= @default_struct_class.new 
            to.send("#{sm.to.name}=", convert_to(to_value, sm.to)) unless to_value.nil?
          end
        end
       rescue Exception => e
        e = MappumException.new(e) unless e.kind_of?(MappumException)
        e.wrap(sm, from_value, to_value)
        raise e
       end 
      end
      if all_nils and map.strip_empty?
        return nil
      end
        return to
      rescue Exception => e
        e = MappumException.new(e) unless e.kind_of?(MappumException)
        e.wrap(map, from, to)
        raise e
      end
    end
    
    protected
    
    def get(object, field, parent_field=nil)
		  if field.kind_of?(String) or field.kind_of?(Symbol)
		    field_name = field
		  else
				unless field.respond_to?(:name)
					return field.value
				end
				if field.name.nil? or object.nil?
					return object
				end
				#for fields targeted at parents go up the tree
				if (not parent_field.nil?) and field.parent != parent_field
				  if object.respond_to?(:_mpum_parent)
				    return get(object._mpum_parent, field, parent_field.parent)
				  else 
				    raise "We hit an element with no parent: #{object.inspect}"
				  end
				end
				field_name = field.name
			end
			begin
				return object.send(field_name)
			rescue NoMethodError => e
			#for open structures field will be defined later
			if object.kind_of?(@default_struct_class)
				return nil
			else
				raise e
			end
	   end
    end
    def convert_to(to, field_def)
      return to
    end
    def convert_from(from, field_def)
      return from
    end
    def add_parent(value, parent)
      #don't work for Fixnums and Floats
      return value if value.kind_of?(Fixnum) or value.kind_of?(Float)
      class << value
        attr_accessor :_mpum_parent
      end
      value._mpum_parent = parent
      return value
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
  class MapMissingException < MappumException
    attr_accessor :from
    def initialize(from, msg=nil)
      msg ||= "Map for class \"#{from.class}\" not found!"
      super(msg)
      @from = from
  end
end
end
