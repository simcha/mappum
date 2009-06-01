module Mappum
  module MapServer
      class Graph
          def initialize(map)
            @map = map
            @struct_from = StrTree.new(nil,0)
            @struct_to = StrTree.new(nil,0)
            @edges = []
            init(@map,@struct_from, @struct_to)
          end
          def getSvg
            cmd = "dot"
            format = "svg"
            xCmd = "#{cmd} -T#{format}"
            dot = getDot
            f = IO.popen( xCmd ,"r+")
            f.print(dot)
            f.close_write
            return f.readlines.join("\n")
          end
          def getDot
            str1 = makeStruct(@struct_from)
            str2 = makeStruct(@struct_to)
            edge = @edges.join
            return <<DOT
digraph structs { node [shape=plaintext]; rankdir=LR;       
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
            to_name, to_path, level_to = get_name_and_path(map.to)
            from_name, from_path, level_from = get_name_and_path(map.from)
              str_from = StrTree.new(struct_from,level_from)
            unless from_name.nil?
              str_from.line = "<TR> <TD COLSPAN=\"2\" PORT=\"#{from_path}\">#{from_name}</TD></TR>\n"
            end
            str_to = StrTree.new(struct_to,level_to)
            unless to_name.nil?
              str_to.line ="<TR> <TD COLSPAN=\"2\" PORT=\"#{to_path}\">#{to_name}</TD></TR>\n"              
            end

            unless map.maps.empty?
              map.maps.each do |sub_map|
                init(sub_map, str_from, str_to)
              end
            else
              # as option? labelfloat=true 
              edge = "struct1:#{from_path} -> struct2:#{to_path} [arrowtail = none arrowhead = vee "
              edge += " URL=\"www.ww/ss#{@edges.size+1}\" fontsize=6 "
              edge += " label=\"#{@edges.size+1}\"  tooltip=\"2\" color=\"black\"];\n"
              
              @edges << edge
            end

          end
          def get_name_and_path(element, level = 0)
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
       attr_accessor :line, :parent,:children
       def initialize(parent, level)
         @parent=parent
         @parent.add(self, level) unless parent.nil?
       end
       
       def add(child, level=0)
         @children ||= []
         if level == 0 
           @children << child  unless @children.include?(child)
         else
           @parent.add(child, level - 1)
         end
       end
      end
      def ==(other)
        return false unless other.kind_of?(StrTree)
        if @line == other.line and @parent == other.parent and @children == other.children
          return true
        end
      end  
  end  
end