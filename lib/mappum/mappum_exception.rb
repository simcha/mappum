module Mappum
   class MappumException < RuntimeError
     attr_accessor :from_name, :to_name, :from, :to, :from_root, :to_root, :mappum_backtrace , :caused_by
     
     def initialize(mess=nil)
       super(mess)
       if mess.kind_of? Exception
         @caused_by = mess 
         set_backtrace(mess.backtrace)
       end
     end
     def wrap(map, from, to)
        
        if map != nil and map != @map #don't store same maps twice
          @map = map 
          from_suffix, to_suffix = "",""
          
		  add_to_mappum_backtrace(map)
		  from_suffix = "[]" if map.from.array?
		  add_from_name(map.from.name, from_suffix)
		  to_suffix = "[]" if map.to.array?
		  add_to_name(map.to.name, to_suffix)
	    end
		@to = to if @to.nil?
		@from = from if @from.nil?
		@to_root = to
		@from_root = from 
	           
     end
     private
     def add_from_name(name,sfx)
       @from_name =  ["/", name.to_s+sfx, @from_name].join("")  unless name.nil?
     end
     def add_to_name(name,sfx)
       @to_name =  ["/", name.to_s+sfx, @to_name].join("") unless name.nil?
     end
     def add_to_mappum_backtrace(map)
       if @mappum_backtrace.nil?
         @mappum_backtrace = []
         @mappum_backtrace << map.from.src_ref
         @mappum_backtrace << map.to.src_ref
       end
       @mappum_backtrace << map.src_ref
     end
   end
end
