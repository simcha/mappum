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
    def transform(from, map=nil, to=nil)

      map ||= @map_catalogue[from.class]

      to ||= map.to.clazz.new unless map.to.clazz.nil?

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

          all_nils = false unless to_array.nil?

          if sm.to.name.nil?
            to = to_array
          else
            to.send("#{sm.to.name}=", to_array)
          end
        else

          all_nils = false unless to_value.nil?

          if sm.to.name.nil?
            to ||= to_value
          elsif 
            to.send("#{sm.to.name}=", to_value)
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