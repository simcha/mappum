# TODO docs
require 'set'
require 'mappum'


module Mappum
  class RubyTransform
    def initialize(map_catalogue)
      @map_catalogue = map_catalogue
    end
    def get(object, field)
      if field.nil?
        return object
      else
        return object.send(field)
      end
    end
    def transform(from, map=nil)

      map ||= @map_catalogue[from.class]

      to = map.to.clazz.new unless map.to.clazz.nil?

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
            to_value = transform(from_value, sm)
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
          if sm.to.name.nil?
            to = to_array
          else
            to.send("#{sm.to.name}=", to_array)
          end
        else
          if sm.to.name.nil?
            to = to_value
          else
            to.send("#{sm.to.name}=", to_value)
          end
        end
        
      end
      return to
    end
  end
end