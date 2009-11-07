require 'facets/kernel/instance_exec'
class Object 
  def >> field
  return {Mappum::DSL::Constant.new(self) => field} if field.kind_of?(Mappum::DSL::Field)
    throw "Constant can be mapped to field only"
  end
end
module Mappum
  module DSL
    class Map
      attr_accessor :def
      def initialize
        @def = Mappum::Map.new
      end
      def map(*attr, &block)
        mapa  = FieldMap.new(attr)
        mapa.def.source = @def.source

        mapa.def.desc = @comment
        @comment = nil
        
        if (not mapa.def.normalized?) && block_given?
          eval_right = mapa.mpun_right.clone
          eval_right.mpun_definition.is_root = true
          eval_left = mapa.mpun_left.clone
          eval_left.mpun_definition.is_root = true
          mapa.instance_exec(eval_left, eval_right, &block)
        elsif block_given?
          mapa.def.func = block
          mapa.def.func_on_nil = true if mapa.mpun_left.kind_of?(Function)
        end 
        @def.maps += mapa.def.normalize
        @def.bidi_maps << mapa.def
        return mapa.def
      end
      #
      # Define condition evaluated before this mapping is applyed.
      # First argument is a label
      # :> - left to right map
      # :< - right to left map
      # Second argument is a block and from elemnt is pased to the block.
      #
      def map_when(label,&condition)
        case label
          when :>, '>'
            @def.when_l2r = condition
          when :<, '<'
            @def.when_r2l = condition
         end 
      end
      #
      # Add comment to mapping.
      #
      def `(str)
        @comment ||= ""
        @comment += str
      end

      # Add prefix to auto map names
      def name_map_prefix(name)
        name_map(:prefix, name)
      end
      #
      # Give name to a map where map is:
      # :<=> - bidirectional map name
      # :> - left to right map name
      # :< - right to left map name
      # :prefix - add prefix to auto generated names
      #
      def name_map(map, name)
          case map
          when :<=>, '<=>'
            @def.name = name.to_s
          when :>, '>'
             @def.l2r_name = name.to_s
          when :<, '<'
             @def.r2l_name = name.to_s
          when :prefix, 'prefix'
             if name.to_s[-1..-1]=='_'
               @def.name_prefix = name.to_s 
             else
               @def.name_prefix = "#{name.to_s}_" 
             end
          end 
      end
      def func
        Mappum::DSL::Function.new        
      end
      def tree(clazz)
        return Field.new(nil, nil, clazz)
      end
    end
    class RootMap < Map
      def initialize(name,source=nil)
        @def = Mappum::RootMap.new(name)
        @def.source = source
      end
      def make_definition &block
        instance_eval(&block)
        @def
      end
    end
    class FieldMap < Map
      attr_accessor :mpun_left, :mpun_right
      def mpun_left=(left_map_dsl)
        @mpun_left=left_map_dsl
        @def.left=left_map_dsl.mpun_definition
      end
      def mpun_right=(right_map_dsl)
        @mpun_right=right_map_dsl
        @def.right=right_map_dsl.mpun_definition
        end
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
            self.mpun_left = Field.new(nil,nil,mapped[0])
          else
            self.mpun_left = mapped[0]
          end
          if(mapped[1]).instance_of?(Class) or (mapped[1]).instance_of?(Symbol)
            @def.strip_empty = false
            self.mpun_right = Field.new(nil,nil,mapped[1])
          else
            self.mpun_right = mapped[1]
          end
        end
        if mapped.instance_of?(Hash) then
          self.mpun_left = mapped.keys[0]
          self.mpun_right = mapped.values[0]
        end
  
        if mapped.instance_of?(Hash) then
          @def.from = @def.left
          @def.to = @def.right
        end

        @def.dict = attr[0][1][:dict] if attr[0].size > type_size
        @def.desc = attr[0][1][:desc] if attr[0].size > type_size
        @def.map_when = attr[0][1][:when] if attr[0].size > type_size
        @def.when_r2l = attr[0][1][:when_r2l] if attr[0].size > type_size
        @def.when_l2r = attr[0][1][:when_l2r] if attr[0].size > type_size
        if @def.normalized? and not (@def.when_r2l.nil? and  @def.when_l2r.nil?)
          raise "r2l and l2r :when functions can be set only on bidirectional maps"  
        end
        if not @def.normalized? and not @def.map_when.nil?
          raise ":when function can be set only on unidirectional maps use :when_r2l and :when_l2r or map_when function"  
        end
        
        @def.submap_alias = attr[0][1][:map] if attr[0].size > type_size
                    
      end   
    end
    #Base class for all mapped elements eg. fields, constants
    class Mappet
      def mpun_definition
        @def
      end
      def <=> field
        [self, field]
      end
  
      def << field
        return {field => self} if field.kind_of?(Mappum::DSL::Mappet)
        return {Constant.new(field) => self}
      end
  
      def >> field
        return {self => field}  if field.kind_of?(Mappum::DSL::Mappet)
        throw "Must map to a field"
      end
    end
    class Constant < Mappet
      def initialize(value)
        @def = Mappum::Constant.new
        @def.value = value
      end
    end

    class Function < Mappet
      def initialize
        @def = Mappum::Function.new
      end
    end
    
    class Field < Mappet
      def initialize(parent, name, clazz, placeholder = false)
        @def =  Mappum::Field.new
        @def.parent = parent
        @def.name = name
        @def.clazz = clazz
        @def.is_array = false
        @def.is_root = false
        @def.is_root = false
        @def.is_placeholder = placeholder
      end
  
      def type(*attr)
        method_missing(:type, *attr)
      end
      def id(*attr)
        method_missing(:id, *attr)
      end
  
      def method_missing(symbol, *args, &block)
        if @def.is_root
          if(symbol == :self)
            return Field.new(@def, nil, args[0], true)
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
        #this functions also indicate Array -> element
        if symbol == :find or symbol == :detect
          @def.is_array = true
        end
        arguments = args.clone
        unless block.nil?
          arguments << "&mappum_block"
          @def.block = block
        end
        if @def.func.nil?
          @def.func =  "self.#{symbol}(#{arguments.join(", ")})"
        else
          @def.func += ".#{symbol}(#{arguments.join(", ")})"
        end
        return self
      end
    end
  end
end
