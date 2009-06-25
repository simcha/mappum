module Mappum
# Base Map class representing mapping betwean two or more types, properties etc.
  class Map
    
    attr_accessor :maps, :bidi_maps, :strip_empty
    
    def initialize
      @maps = []
      @bidi_maps = []
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
    def get_bidi_map(name)
      #TODO optimize
      mpa = @bidi_maps.find{|m| m.right.clazz == name or m.right.clazz.to_s == name.to_s }
      mpa ||= @bidi_maps.find{|m| m.left.clazz == name or m.left.clazz.to_s == name.to_s }
      return mpa unless mpa.nil?
      
      return @bidi_maps.find{|m| "#{m.left.clazz}-to-from-#{m.right.clazz}" == name.to_s}
    end
    def list_map_names(full_list = false)
      list = []
      list += @maps.collect{|m| "#{m.from.clazz}-to-#{m.to.clazz}"}
      list += @maps.collect{|m|m.from.clazz} if full_list
      return list
    end
    def list_bidi_map_names
      list = []
      list += @bidi_maps.collect{|m| "#{m.left.clazz}-to-from-#{m.right.clazz}"}
      return list
    end
  end
  
  class FieldMap < Map
    attr_accessor :dict, :desc, :left, :right, :func, :to, :from, :func_on_nil
    # True if map is unidirectional. Map is unidirectional
    # when maps one way only.
    def normalized?
      not @from.nil?
    end
    
    def normalize
      #if bidirectional
      if not normalized?
        map_l = self.clone
        map_l.to = self.left
        map_l.from = self.right
        map_l.maps = self.maps.select do |m|
          m.to.parent == map_l.to
        end
        
        map_l.dict = self.dict.invert unless self.dict.nil?
  
        map_r = self.clone
        map_r.to = self.right
        map_r.from = self.left
        map_r.maps = self.maps.select do |m|
          m.to.parent == map_r.to
        end
  
        [map_l, map_r]
      else
        [self]
      end
    end
    def simple?
        @func.nil? && @dict.nil? && @desc.nil? && 
          @maps.empty? && @bidi_maps.empty? && @right.func.nil? && @left.func.nil?
    end
    def func_on_nil?
      @func_on_nil
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
  class Constant <  Struct.new(:value) 
    def parent
      nil
    end
    def is_array
      @value.kind_of?(Array)
    end
    def func
      nil      
    end
  end
  class Function
    def parent
      nil
    end
    def array?
      false
    end
    def func
      nil      
    end
    def value
      nil
    end
  end
end