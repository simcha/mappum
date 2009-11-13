module Mappum
# Base Map class representing mapping betwean two or more types, properties etc.
  class Map
    
    attr_accessor :maps, :bidi_maps, :strip_empty, :source
    
    def initialize
      @maps = []
      @bidi_maps =[]
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
      @maps_by_name, @maps_by_from = {},{}
      @maps_by_from_to = {}
      @bidi_maps_by_name, @bidi_maps_by_class = {},{}
    end
    def [](arg1, to_class=nil)
      from_class = arg1
      unless to_class.nil?
        key = [from_class.to_s, to_class.to_s]
        return @maps_by_from_to[key]
      end
      mpa = @maps_by_from[from_class.to_s]
      return mpa unless mpa.nil?
      return @maps_by_name[arg1.to_s]
    end
    def get_bidi_map(name)
      mpa = @bidi_maps_by_class[name.to_s]
      return mpa unless mpa.nil?
      
      return @bidi_maps_by_name[name.to_s]
    end
    def list_map_names(full_list = false)
      list = []
      list += @maps_by_name.collect{|k,v| k}
      list += @maps_by_from.collect{|k,v| k} if full_list
      return list
    end
    def list_bidi_map_names
      list = []
      list += @bidi_maps_by_name.collect{|k, v| k}
      return list
    end
    #
    # Add array of maps to catalogue.
    # Makes name index for map search.
    # Map names will be used and no 2 names can be the same in the catalogue/
    # Class names will be used for maps that are unique in regard to mapping from and to classes.
    #
    def add(map)
      if map.normalized?
        raise "Duplicate map name #{map.name}" if @maps_by_name.include?(map.name)
        @maps_by_name[map.name] = map
        #When there are 2 maps from same class to other classes non will be found by default
        add_to_index(@maps_by_from, map.from.clazz.to_s, map)

        #When there are 2 maps from same class to same class non will be found by default
        from_to_key = [map.from.clazz.to_s, map.to.clazz.to_s]
        add_to_index(@maps_by_from_to, from_to_key, map)
      else
        raise "Duplicate map name #{map.name}" if @bidi_maps_by_name.include?(map.name)
        @bidi_maps_by_name[map.name] = map

        add_to_index(@bidi_maps_by_class, map.left.clazz.to_s, map)
        add_to_index(@bidi_maps_by_class, map.right.clazz.to_s, map)
      end
    end
    #
    # Add value to index in key position unless there is a value for such a key
    # in such a case put nil in the index to mark position invalid
    #
    private 
    def add_to_index(index, key, map)
      if index.include?(key)
        index[key] = nil
      else
        index[key] = map
      end
    end
  end
  
  class FieldMap < Map
    attr_accessor :dict, :desc, :left, :right, :func, :block, :to, :from, :func_on_nil, :submap_alias
    attr_accessor :name, :l2r_name, :r2l_name, :name_prefix, :map_when, :when_r2l, :when_l2r
    attr_accessor :to_array_take, :to_array_take_r2l, :to_array_take_l2r
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
        map_r2l.map_when = self.when_r2l
        map_r2l.when_r2l, map_r2l.when_l2r = nil, nil
        map_r2l.to_array_take = self.to_array_take_r2l
        map_r2l.to_array_take_r2l, map_r2l.to_array_take_l2r = nil, nil
        map_r2l.maps = self.maps.select do |m|
          m.to.parent == map_r2l.to
        end
        
        map_r2l.dict = self.dict.invert unless self.dict.nil?
  
        map_l2r = self.clone
        map_l2r.to = self.right
        map_l2r.from = self.left
        map_l2r.name = self.l2r_name
        map_l2r.r2l_name, map_l2r.l2r_name = nil, nil
        map_l2r.map_when = self.when_l2r
        map_l2r.when_r2l, map_l2r.when_l2r = nil, nil
        map_l2r.to_array_take = self.to_array_take_l2r
        map_l2r.to_array_take_r2l, map_l2r.to_array_take_l2r = nil, nil
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
  class Field < Struct.new(:name, :clazz, :parent, :func, :block, :is_root, :is_placeholder)
    #define is_array separetly to exclude it from equals
    attr_accessor :is_array
    def array?
      is_array
    end
    def placeholder?
      is_placeholder
    end
  end
  class Constant <  Struct.new(:value,:parent) 
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
  class Function <  Struct.new(:parent) 
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
