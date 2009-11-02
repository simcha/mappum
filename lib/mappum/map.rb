module Mappum
# Base Map class representing mapping betwean two or more types, properties etc.
  class Map
    
    attr_accessor :maps, :bidi_maps, :strip_empty, :source
    
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
    def [](arg1, to_class=nil)
      from_class = arg1
      #TODO optimize
      unless to_class.nil?
        return @maps.find{|m| (m.from.clazz == from_class or m.from.clazz.to_s == from_class.to_s) and
                              (m.to.clazz == to_class or m.to.clazz.to_s == to_class.to_s)}
      end
      mpa = @maps.find{|m| m.from.clazz == from_class or m.from.clazz.to_s == from_class.to_s }
      return mpa unless mpa.nil?
      return @maps.find{|m| m.name == arg1.to_s}
    end
    def get_bidi_map(name)
      #TODO optimize
      mpa = @bidi_maps.find{|m| m.right.clazz == name or m.right.clazz.to_s == name.to_s }
      mpa ||= @bidi_maps.find{|m| m.left.clazz == name or m.left.clazz.to_s == name.to_s }
      return mpa unless mpa.nil?
      
      return @bidi_maps.find{|m| m.name == name.to_s}
    end
    def list_map_names(full_list = false)
      list = []
      list += @maps.collect{|m| m.name}
      list += @maps.collect{|m|m.from.clazz} if full_list
      return list
    end
    def list_bidi_map_names
      list = []
      list += @bidi_maps.collect{|m| m.name}
      return list
    end
  end
  
  class FieldMap < Map
    attr_accessor :dict, :desc, :left, :right, :func, :block, :to, :from, :func_on_nil, :submap_alias
    attr_accessor :name, :l2r_name, :r2l_name, :name_prefix
    # True if map is unidirectional. Map is unidirectional
    # when maps one way only.
    def normalized?
      not @from.nil?
    end
    def name
      return @name unless @name.nil?
      if normalized?
        @name = "#{@name_prefix}#{@from.clazz}_to_#{@to.clazz}"
      else
        @name =  "#{@name_prefix}#{@left.clazz}_to_from-#{@right.clazz}"
      end
      return @name
    end
    def normalize
      #if bidirectional
      if not normalized?
        map_r2l = self.clone
        map_r2l.to = self.left
        map_r2l.from = self.right
        map_r2l.name = self.r2l_name
        map_r2l.r2l_name, map_r2l.l2r_name = nil, nil
        map_r2l.maps = self.maps.select do |m|
          m.to.parent == map_r2l.to
        end
        
        map_r2l.dict = self.dict.invert unless self.dict.nil?
  
        map_l2r = self.clone
        map_l2r.to = self.right
        map_l2r.from = self.left
        map_l2r.name = self.l2r_name
        map_l2r.r2l_name, map_l2r.l2r_name = nil, nil
        map_l2r.maps = self.maps.select do |m|
          m.to.parent == map_l2r.to
        end
  
        [map_r2l, map_l2r]
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
  class Field < Struct.new(:name, :clazz, :parent, :func, :block, :is_root, :is_array, :is_placeholder)
    def array?
      is_array
    end
    def placeholder?
      is_placeholder
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
