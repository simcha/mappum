# TODO docs
require 'set'

module Mappum
  def self.catalogue_add(name, &block)
    @catalogue ||= {}
    @catalogue[name] ||= RootMap.new(name)
    @catalogue[name].instance_eval(&block)
  end
  def self.catalogue(name)
    @catalogue[name]
  end
  class Map
    attr_accessor :maps
    def initialize
      @maps = []
      @strip_empty = true
    end
    def strip_empty?
      @strip_empty
    end
    def self.const_missing(sym)
      return ModulePlaceholder.new sym
    end
    def self.map(*attr, &block)
      @mp ||= self.new(self.name)
      @mp.map(*attr, &block)
    end
    def map(*attr, &block)
    
      mapa  = FieldMap.new(attr)

      if (not mapa.normalized?) && block_given?
        eval_right = mapa.right.clone
        eval_right.mpun_field_definition.is_root = true
        eval_left = mapa.left.clone
        eval_left.mpun_field_definition.is_root = true
        mapa.instance_exec(eval_left, eval_right, &block)
      elsif block_given?
        mapa.func = block
      end 
      @maps += mapa.normalize
      return mapa
    end
    def self.[](clazz)
      @mp ||= self.new(self.name)
      @mp[clazz]
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
      if clazz.instance_of?(Class)
        return @maps.find{|m| m.from.clazz == clazz.name.to_sym}
      else
        return @maps.find{|m| m.from.clazz == clazz}
      end
    end
  end
  class FieldMap < Map
    attr_accessor :dict, :left, :right, :func, :to, :from
   
    def initialize(*attr)
      super()
      mapped = attr[0][0]
      if mapped.instance_of?(Array) then
        if(mapped[0]).instance_of?(ModulePlaceholder) or (mapped[0]).instance_of?(Symbol)
          @strip_empty = false
          @left = Field.new(nil,nil,mapped[0].to_sym)
        else
          @left = mapped[0]
        end
        if(mapped[1]).instance_of?(ModulePlaceholder) or (mapped[1]).instance_of?(Symbol)
          @strip_empty = false
          @right = Field.new(nil,nil,mapped[1].to_sym)
        else
          @right = mapped[1]
        end
      end
      if mapped.instance_of?(Hash) then
        @left = mapped.keys[0]
        @right = mapped.values[0]
      end

      if mapped.instance_of?(Hash) then
        @from = @left.mpun_field_definition
        @to = @right.mpun_field_definition
      end
      @dict = attr[0][1][:dict] if attr[0].size > 1
    end
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
      clazz_name = nil
      if args[0].instance_of?(Class)
        clazz_name = args[0].name.to_sym
      else
        clazz_name = args[0].to_sym
      end

      return Field.new @parent, symbol, clazz_name
    end
  end
  class FieldDefinition < Struct.new(:name, :clazz, :parent, :func, :is_root, :is_array)
    def array?
      @is_array
    end
  end

  class Field

    def mpun_field_definition
      @def
    end

    def initialize(parent, name, clazz)
      @def =  FieldDefinition.new
      @def.parent = parent
      @def.name = name
      @def.clazz = clazz
      @def.is_array = false
      @def.is_root = false
    end

    def <=> field
      [self, field]
    end

    def << field
      {field => self}
    end

    def >> field
      {self => field}
    end
    def type(*attr)
      method_missing(:type, *attr)
    end
    def id(*attr)
      method_missing(:id, *attr)
    end

    def method_missing(symbol, *args)
      clazz_name = nil
      if args[0].instance_of?(Class)
        clazz_name = args[0].name.to_sym
      elsif not args[0].nil?
        clazz_name = args[0].to_sym
      end

      if @def.is_root
        if(symbol == :self)
          return  Field.new @def, nil, clazz_name
        end
        return Field.new @def, symbol, clazz_name
      end

      if symbol == :[]
        #empty [] is just indication that field is an array not function      
        if args.size == 0
          @def.is_array = true
          return self
        end
        #[n] indicates both mapping function and array
        if args.size == 1 and args[0].instance_of?(Fixnum)
          @def.is_array = true
        end
      end
      if @def.func.nil?
        @def.func =  "self.#{symbol}(#{args.join(", ")})"
      else
        @def.func += ".#{symbol}(#{args.join(", ")})"
      end

      return self
    end
  end
  class ModulePlaceholder < Module
    def initialize(sym, parent=nil)
      if parent.nil?
        @name = sym
      else
        @name = "#{parent}::#{sym}".to_sym
      end
    end
    def const_missing sym
      ModulePlaceholder.new sym, @name
    end
    def <=> other_module
      [self, other_module]
    end
    def to_sym
     @name
    end
  end
end