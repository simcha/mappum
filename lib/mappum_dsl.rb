module Mappum
  module DSL
    class Map
      attr_accessor :def
      
      def initialize
        @def = Mappum::Map.new
      end
      def map(*attr, &block)
        mapa  = FieldMap.new(attr)
  
        if (not mapa.def.normalized?) && block_given?
          eval_right = mapa.def.right.clone
          eval_right.mpun_field_definition.is_root = true
          eval_left = mapa.def.left.clone
          eval_left.mpun_field_definition.is_root = true
          mapa.instance_exec(eval_left, eval_right, &block)
        elsif block_given?
          mapa.def.func = block
        end 
        @def.maps += mapa.def.normalize
        return mapa.def
      end
  
  
      def tree(clazz)
        return Field.new(nil, nil, clazz)
      end
    end
    class RootMap < Map
      def initialize(name)
        @def = Mappum::RootMap.new(name)
      end
      def make_definition &block
        instance_eval(&block)
        @def
      end
    end
    class FieldMap < Map
      def initialize(*attr)
        @def = Mappum::FieldMap.new
        type_size = 1
        if attr == [[nil]]
          raise """Can't make map for [[nil]] arguments. 
          Can be that You define top level class mapping with \"<=>\" please use \",\" instead (we know its a Bug). """
        end
        mapped = attr[0][0]
        if attr[0][0].instance_of?(Class) or attr[0][0].instance_of?(Symbol) and
               attr[0][1].instance_of?(Class) or attr[0][1].instance_of?(Symbol)
           mapped = [attr[0][0], attr[0][1]]
           type_size = 2   
        end
        
        if mapped.instance_of?(Array) then
          if(mapped[0]).instance_of?(Class) or (mapped[0]).instance_of?(Symbol)
            @def.strip_empty = false
            @def.left = Field.new(nil,nil,mapped[0])
          else
            @def.left = mapped[0]
          end
          if(mapped[1]).instance_of?(Class) or (mapped[1]).instance_of?(Symbol)
            @def.strip_empty = false
            @def.right = Field.new(nil,nil,mapped[1])
          else
            @def.right = mapped[1]
          end
        end
        if mapped.instance_of?(Hash) then
          @def.left = mapped.keys[0]
          @def.right = mapped.values[0]
        end
  
        if mapped.instance_of?(Hash) then
          @def.from = @def.left.mpun_field_definition
          @def.to = @def.right.mpun_field_definition
        end

        @def.dict = attr[0][1][:dict] if attr[0].size > type_size
      end   
    end


    
    class Field
  
      def mpun_field_definition
        @def
      end
  
      def initialize(parent, name, clazz)
        @def =  Mappum::Field.new
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
        if @def.is_root
          if(symbol == :self)
            return  Field.new(@def, nil, args[0])
          end
          return Field.new(@def, symbol, args[0])
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
  end
end