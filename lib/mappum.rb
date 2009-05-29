# TODO docs
require 'set'
require 'mappum_dsl'

module Mappum
  def self.catalogue_add(name = "ROOT", &block)
    @catalogue ||= {}
    @catalogue[name] ||= RootMap.new(name)
    @catalogue[name].maps += DSL::RootMap.new(name).make_definition(&block).maps
  end
  def self.catalogue(name = "ROOT")
    name = "ROOT" if name.nil?
    @catalogue[name]
  end
  
  # Base Map class representing mapping betwean two or more types, properties etc.
  class Map
    
    attr_accessor :maps, :strip_empty
    
    def initialize
      @maps = []
      @strip_empty = true
    end
    # When value of mapped property is null remove property.
    def strip_empty?
      @strip_empty
    end
  end
  
  
  class RootMap < Map
    attr_accessor :name
    def initialize(name)
      super()
      @name = name
      @strip_empty = false
    end
    def [](clazz)
      #TODO optimize
      mpa = @maps.find{|m| m.from.clazz == clazz or m.from.clazz.to_s == clazz.to_s }
      return mpa unless mpa.nil?
      return @maps.find{|m| "#{m.from.clazz}-to-#{m.to.clazz}" == clazz.to_s}
    end
    def list_map_names
      list = []
      list += @maps.collect{|m|m.from.clazz}
      list += @maps.collect{|m| "#{m.from.clazz}-to-#{m.to.clazz}"}
      return list
    end
  end
  
  class FieldMap < Map
    attr_accessor :dict, :left, :right, :func, :to, :from
    # True if map is unidirectional. Map is unidirectional
    # when maps one way only.
    def normalized?
      not @from.nil?
    end
    
    def normalize
      #if bidirectional
      if not normalized?
        map_l = self.clone
        map_l.to = self.left.mpun_field_definition
        map_l.from = self.right.mpun_field_definition
        map_l.maps = self.maps.select do |m|
          m.from.parent == map_l.from
        end
        
        map_l.dict = self.dict.invert unless self.dict.nil?

        map_r = self.clone
        map_r.to = self.right.mpun_field_definition
        map_r.from = self.left.mpun_field_definition
        map_r.maps = self.maps.select do |m|
          m.from.parent == map_r.from
        end

        [map_l, map_r]
      else
        [self]
      end
    end
  end
  class Tree
    attr_accessor :parent

    def initialize(parent)
      @parent = parent
    end
    def method_missing(symbol, *args)
      return Field.new(@parent, symbol, args[0])
    end
  end
  class Field < Struct.new(:name, :clazz, :parent, :func, :is_root, :is_array)
    def array?
      @is_array
    end
  end


end