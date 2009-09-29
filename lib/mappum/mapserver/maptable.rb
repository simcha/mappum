module Mappum
  module MapServer
    class MapTable
      attr_reader :edge_maps
      
      def initialize(map)
        unless map.normalized?
           raise "Tables are for unidirectional maps only"
        end
        @edge_maps = {}
        
        @max_llevel, @max_rlevel = 0, 0
        findMaxLevel(map)
        @table = "<TABLE BORDER=1 CELLPADDING=3 CELLSPACING=1 RULES=ALL FRAME=BOX>" + getRowsFrom(map).join("\n") + "</TABLE>"
      end
      def getHtml()
        return @table
      end
      private
      def getRowsFrom(map,rlevel=0,llevel=0)
                
        lname = map.from.name.to_s if map.from.respond_to?(:name)
        rname = map.to.name.to_s if map.to.respond_to?(:name)

        lname ||= "" 
        rname ||= ""

        lname += "(#{map.from.clazz.to_s})" if map.from.respond_to?(:clazz) and not map.from.clazz.nil?
        rname += "(#{map.to.clazz.to_s})" if map.to.respond_to?(:clazz) and not map.to.clazz.nil?
       
        
        llevel = llevel -1 if  map.from.respond_to?(:placeholder?) and map.from.placeholder?
        rlevel = rlevel -1 if  map.to.respond_to?(:placeholder?) and map.to.placeholder?
        
        rows=[]
        oper = ""
        map.maps.each do |submap|
          rows += getRowsFrom(submap,rlevel+1,llevel+1)
        end
        
        oper = "&gt;&gt;" if map.maps.empty?
        oper = "&gt;f&gt;"  unless map.func.nil?
        unless map.dict.nil?
          @edge_maps[@edge_maps.size+1]=map
          oper = "&gt;d<font style='vertical-align: super; font-size: smaller;'>#{@edge_maps.size}</font>&gt;"
        end
        
        oper = "set constant \"#{map.from.value.to_s}\""  if map.from.kind_of?(Constant)
        oper = "Func call"  if map.from.kind_of?(Function)
        oper += "<BR/><FONT style='color: #009020;'> #{map.desc} </FONT>" unless map.desc.nil?
        
        lempy_td = ""
        llevel.times{lempy_td += "<TD> </TD>"}
        rempy_td = ""
        rlevel.times{rempy_td += "<TD> </TD>"}
        
        lstyle = ""
        #color structure names
        lstyle = "bgcolor='#AAAAAA'" if not map.maps.empty? and map.from.respond_to?(:placeholder?) and not map.from.placeholder?
        rstyle = ""  
        #color structure names
        rstyle = "bgcolor='#AAAAAA'" if not map.maps.empty? and map.to.respond_to?(:placeholder?) and not map.to.placeholder?
                  
        row = "<TR>#{lempy_td}<TD #{lstyle} colspan='#{@max_llevel +1 - llevel}'>#{lname}</TD>"
        row += "<TD align='center'>#{oper}</TD>"
        row += "#{rempy_td}<TD #{rstyle} colspan='#{@max_rlevel+1 - rlevel}'>#{rname}</TD></TR>"
                        
        rows = [row] + rows
        return rows
      end
      def findMaxLevel(map,rlevel=0,llevel=0)
        map.maps.each do |submap|
           findMaxLevel(submap,rlevel+1,llevel+1)
        end
        @max_llevel = [@max_llevel,llevel].max                   
        @max_rlevel = [@max_rlevel,rlevel].max   
      end
    end
  end
end