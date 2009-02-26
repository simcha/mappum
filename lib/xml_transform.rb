# TODO docs
require 'set'
require 'mappum'
require 'ostruct'
require 'soap/marshal'
require 'rubygems'
gem 'builder'
require 'builder'
require 'xml'

module Mappum
  class XmlTransform
    def initialize(map_catalogue)
      @map_catalogue = map_catalogue
      @default_struct_class = Mappum::OpenStruct;
    end
    def get(object, field)
      if field.nil?
        return object
      else
        return object.content
      end
    end
    def transform(from_xml, map=nil)
      from = XML::Parser.string(from_xml).parse.root

      builder ||= Builder::XmlMarkup.new

      map ||= @map_catalogue[from.name]

      doc = builder.tag!(map.to.clazz) { |to|
        transform_inner(from, map, to)
      }
      return doc

    end
    def transform_inner(from_parent, map=nil, to=nil)

      map ||= @map_catalogue[from_parent.name]

      all_nils = true

      from_parent.each_element do |from|
        sm = map[:name => from.name]
        to_value = nil

        from_value = get(from, sm.from.name)

        if sm.maps.empty?
          to_value = from_value
        elsif not from_value.nil?
          if from_value.instance_of?(Array)
            sm_v = sm.clone
            sm_v.from.is_array = false
            sm_v.to.is_array = false
            #to_value = from_value.collect{|v| transform_inner(v, sm_v)}
          else
            #to_value = transform_inner(from_value, sm, get(to, sm.to.name))
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
            to ||= @default_struct_class.new
            to.send("#{sm.to.name}=", to_array)
          end
        else

          all_nils = false unless to_value.nil?

          if sm.to.name.nil?
            to ||= to_value
          elsif
            to ||= @default_struct_class.new
            to.tag!(sm.to.name) do |to_obj|
              to_obj.text!(to_value) unless to_value.nil?
            end
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