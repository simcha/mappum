module Mappum
  module MapServer
      class Graph
        attr_reader :edge_maps
        def initialize(map)
            @map = map
            @root = []
            @struct_from = StrTree.new(nil,0,@root)
            @struct_from.name = "struct1"
            @struct_to = StrTree.new(nil,0,@root)
            @struct_to.name = "struct2"
            @edges = []
            @edge_maps = {}
            init(@map,@struct_from, @struct_to)
          end
          def getSvg
            cmd = "dot"
            format = "svg"
            xCmd = "#{cmd} -T#{format}"
            puts dot = getDot
            f = IO.popen( xCmd ,"r+")
            f.print(dot)
            f.close_write
            return f
          end
          def getPng
            cmd = "dot"
            format = "png"
            xCmd = "#{cmd} -T#{format}"
            dot = getDot
            f = IO.popen( xCmd ,"r+")
            f.print(dot)
            f.close_write
            return f
          end
          def getDot
            str1 = makeStruct(@struct_from)
            str2 = makeStruct(@struct_to)
            edge = @edges.join
            return <<DOT
digraph structs { node [shape=plaintext]; rankdir=LR;  nodesep=0.1;    
 struct1 [
             label=<
              #{str1}
            >
            ]; 
 struct2 [
             label=<
              #{str2}
             >
            ];
            #{@root.collect { |struct| struct.line}}
            #{edge}
            
            }              
DOT
          end
          
          private
          
          def makeStruct(struct_tree)
            str = struct_tree.line || ""
            unless struct_tree.children.nil? or struct_tree.children.empty?
              str += "<TR><TD></TD> <TD CELLPADDING=\"1\">" unless struct_tree.parent.nil? 
              str += "<TABLE BORDER=\"0\" CELLBORDER=\"1\" CELLSPACING=\"0\" BGCOLOR=\"cornsilk2\">\n"
              st = struct_tree.children.collect { |child| makeStruct(child)}
              st.uniq!          
              str += st.join + "</TABLE>" 
              str += "</TD></TR>\n" unless struct_tree.parent.nil? 
            end
            return str
          end
          def init(map, struct_from, struct_to)
            if map.normalized?
              map_from, map_to = map.from, map.to
            else
              map_from, map_to = map.left, map.right
            end
            to_name, to_path, level_to = get_name_and_path(map_to) 
            from_name, from_path, level_from = get_name_and_path(map_from)

            str_from = StrTree.new(struct_from,level_from, @root)
            unless from_name.nil?
              if level_from > -1
                str_from.line = "<TR> <TD COLSPAN=\"2\" PORT=\"#{from_path}\">#{from_name}</TD></TR>\n"
              else
                str_from.line = "#{from_path} [ label = <\"#{from_name}\">];\n"
              end
            end
            str_to = StrTree.new(struct_to,level_to,@root)
            unless to_name.nil?
              if level_to > -1
                str_to.line ="<TR> <TD COLSPAN=\"2\" PORT=\"#{to_path}\">#{to_name}</TD></TR>\n"              
              else
                str_to.line = "#{to_path} [ label = <\"#{to_name}\">];\n"
              end
            end
            maps = []
            if  map.normalized?
              maps = map.maps
            else
              maps = map.bidi_maps
            end
            
            
            unless maps.empty?
              maps.each do |sub_map|
                if(map.normalized? or sub_map.left.parent == map_from or 
                  sub_map.right.parent == map_to)
                
                  init(sub_map, str_from, str_to)
                else
                  init(sub_map, str_to, str_from)
                end
              end
            else
              # as option? labelfloat=true 
              from_ref = "#{str_from.root.name}:#{from_path}" if level_from > -1
              to_ref = "#{str_to.root.name}:#{to_path}" if level_to > -1
              from_ref ||= from_path
              to_ref ||= to_path
              edge = "#{from_ref} -> #{to_ref} [" 
              if map.normalized?
                edge += " arrowtail = none tooltip=\"#{from_name} >> #{to_name}\" "
              else 
                edge += " arrowtail = vee tooltip=\"#{from_name} <=> #{to_name}\" "
              end
              edge += " arrowhead = vee URL=\"##{@edges.size+1}\" fontsize=10 "
              unless map.simple?
                edge += " label=\"#{@edges.size+1}\" labeltooltip = \"#{@edges.size+1}: #{from_name} >> #{to_name}\"" 
              end
              color = "black"
              color = "blue" if level_to == -1 or level_from == -1
              edge += " minlen=\"3\" color=\"#{color}\"];\n"
              
              @edges << edge
              unless map.simple?
                  @edge_maps[@edges.size] = map             
              end
            end

          end
          def get_name_and_path(element, level = 0)
            #on non filed elements
            if element.kind_of?(Function)
              return "Function", "c#{element.__id__.abs}", -1              
            end 
            if element.kind_of?(Constant)
              return element.value.to_s, "c#{element.__id__.abs}", -1              
            end 
          
            name = element.name
            if element.parent.nil?
              #root element
              name ||= element.clazz.to_s
            else
              level = level + 1 if name.nil?
              pname, path, level = get_name_and_path(element.parent, level) 
            end
            path = "#{path}v#{name}".gsub(":","vv") unless name.nil?
            name = "#{name}[]" if not name.nil? and element.is_array
            return name, path, level
          end
      end 
      class StrTree
       attr_accessor :line, :parent,:children, :name
       def initialize(parent, level, root)
         @parent=parent  if level > -1
         root << self if level == -1
         @parent.add(self, level) unless @parent.nil?
       end
       
       def add(child, level=0)
         @children ||= []
         if level == 0 
           @children << child  unless @children.include?(child)
         else
           @parent.add(child, level - 1)
         end
       end
       def ==(other)
         return false unless other.kind_of?(StrTree)
         if @line == other.line and @parent == other.parent and @children == other.children
           return true
         end
       end 
       def root
         return parent.root unless parent.nil?
         return self         
       end
      end
  end  
end
