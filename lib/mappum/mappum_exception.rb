module Mappum
   class MappumException < RuntimeError
     attr_accessor :from_name, :to_name, :from, :to, :from_root, :to_root, :mappum_backtrace 
     def wrap(map, from, to)
        add_to_mappum_backtrace(map) unless map.nil?
        add_from_name map.from.name unless map.nil?
        add_to_name map.to.name unless map.nil?
        @to = to if @to.nil?
        @from = from if @from.nil?
        @to_root = to
        @from_root = from        
     end
     private
     def add_from_name(name)
       @from_name =  ["/", name, @from_name].join("")  unless name.nil?
     end
     def add_to_name(name)
       @to_name =  ["/", name, @to_name].join("") unless name.nil?
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
