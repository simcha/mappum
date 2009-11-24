require 'rubygems'
gem 'soap4r'
require 'mappum/xml_transform'
require 'soap/marshal'
require 'mappum/mapserver/mapgraph'
require 'mappum/mapserver/maptable'
require 'syntax/convertors/html'
require 'sinatra/base'
require 'erb'

module Mappum
  class Mapserver < Sinatra::Default
    set :views => File.join(File.dirname(__FILE__), 'views')
    set :public => File.join(File.dirname(__FILE__), 'public')
    set :show_exceptions => false
    set :raise_errors => false    
    configure do
      set :schema_dir => 'schema', :map_dir => 'map', :tmp_dir => nil
      set :catalogue => nil
      set :port => 9292      

      
      @wl = Mappum::WorkdirLoader.new('schema', 'map')
      @wl.generate_and_require
    end
    helpers do
      alias_method :h, :escape_html

      def explain_func(element)
        name = element.name.to_s
        name ||= "self"    
        func = element.func.gsub(/^self/,name)
        #replace [](1) with [1]
        func = func.gsub(/\.\[\]\((.*)\)/,"[\\1]")
        return "Simple function call: \"#{func}\"<br/>"
      end
      def explain(map)
        str=""
        if not map.right.nil? and not map.right.func.nil?
          str+= explain_func(map.right)
        elsif not map.from.nil? and not map.from.func.nil?
          str+= explain_func(map.from)
        end
        unless map.func.nil?
          str+= "Multiline function call (see source)<br/>"
        end
        unless map.dict.nil?
          str+= "Dictionary mapping:<br/>"
          str+= "<table border=\"1\">"
          str+= "<tr><td>#{map.left.name}</td><td>#{map.right.name}</td></tr>"
          map.dict.each do |k,v|
            str+= "<tr><td>#{k}</td><td>#{v}</td></tr>"
          end
          str+= "</table>"
        end
        return str
      end
      def get_xmlns(namespace)
        @namespaces ||= {}
        @i ||= 0
        @namespaces[namespace] = "ns#{@i+=1}" unless @namespaces.include?(namespace)
        return @namespaces[namespace]
      end
    end
    #make get methods for xsd files
    Dir.glob('schema'+'/**/*.xsd') do |filename1|
      get "/"+filename1 do
        [200, {"Content-Type" => "text/xml"}, IO.read(filename1)]
      end
    #make get methods for map files
    Dir.glob('map'+'/**/*.rb') do |filename|
      get "/"+filename do
        convertor = Syntax::Convertors::HTML.for_syntax "ruby"
        @body = convertor.convert( IO.read(filename) ) 
        
        [200, {"Content-Type" => "text/html"}, erb(:rubysource)]
      end
    end
   end
    post "*/transform" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      map_name = nil
      map_name = params["map"] unless params["map"].nil? or params["map"] == "auto_select"
      from_qname_str = params["from_qname"] unless params["from_qname"].nil? or params["from_qname"] == "auto_select"
      from_qname = nil
      unless from_qname_str.nil? or from_qname_str==''
        /^\{([^}]*)\}(.*)$/  =~ from_qname_str
        from_qname = XSD::QName.new($1,$2)
      end
      force_openstruct = false
      force_openstruct = params["ignore"] unless params["map"].nil?

      rt = Mappum::XmlTransform.new(@catalogue, force_openstruct)
      
      xml = params["doc"]

      content = rt.transform(xml,map_name, from_qname)
      
      [200, {"Content-Type" => "text/xml"}, [content]]
    end
    post "*/transform-ws" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"
   
      map_name = env["HTTP_SOAPACTION"] unless env["HTTP_SOAPACTION"].nil? or env["HTTP_SOAPACTION"] == ""
      #remove "" if present 
      map_name = map_name[1..-2] if map_name =~ /^".*"$/
      
      rt = Mappum::XmlTransform.new(@catalogue)
      
      xml = env["rack.input"].read
      begin
        content = rt.transform(xml,map_name)
      rescue Exception => e
        @error = e
        return [200, {"Content-Type" => "text/xml"}, [erb(:'ws-error')]]
      end          
      return [200, {"Content-Type" => "text/xml"}, [content]]
    end
    get "*/transform-ws.wsdl" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      @xml_imports = {}
      Dir.glob('schema'+'/**/*.xsd') do |xsd_file|
        namespace = XmlSupport.get_target_ns(xsd_file)
        @xml_imports[xsd_file] = namespace unless namespace.nil?
        #FIXME log warning
      end
 
      @xml_maps = []
      @xml_elements = Set.new
      Mappum.catalogue(@catalogue).list_map_names.each do |mapname|
        map = Mappum.catalogue(@catalogue)[mapname]
        
        from_qname = XSD::Mapping::Mapper.get_qname_from_class(map.from.clazz)
        @xml_elements << from_qname unless from_qname.nil?
        from_qname ||= XSD::QName.new(nil,"any")
        
        
        to_qname = XSD::Mapping::Mapper.get_qname_from_class(map.to.clazz)
        @xml_elements << to_qname unless to_qname.nil?
        to_qname ||= XSD::QName.new(nil,"any")
        
        @xml_maps << [mapname, from_qname, to_qname]
      end
      
      [200, {"Content-Type" => "text/xml"}, [erb(:'transform-ws.wsdl')]]    end

    get "*/svggraph" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      map_name = params["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map " + map_name]] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/svg+xml"}, graph.getSvg]
            
    end
    get "*/maptable" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      @map_name = params["map"]
      @map = Mappum.catalogue(@catalogue)[@map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map " + @map_name]] if @map.nil?
      @maptable = Mappum::MapServer::MapTable.new(@map)
      @edge_maps = @maptable.edge_maps.keys.sort.collect{|k| [k, @maptable.edge_maps[k], explain(@maptable.edge_maps[k])]}

      [200, {"Content-Type" => "text/html"}, [erb(:maptable)]]
            
    end

    get "*/pnggraph" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      map_name = params["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map '#{map_name}'"]] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/png"}, graph.getPng]
            
    end 
    get "*/doc" do
      @catalogue = params[:splat][0] || "ROOT"
      @catalogue = @catalogue[1..-1] if @catalogue[0..0] == "/"

      @map_name = params["map"]
      @map = Mappum.catalogue(@catalogue).get_bidi_map(@map_name)
      @map ||= Mappum.catalogue(@catalogue)[@map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map " + @map_name]] if @map.nil?
      graph = Mappum::MapServer::Graph.new(@map)
      @edge_maps = graph.edge_maps.keys.sort.collect{|k| [k, graph.edge_maps[k], explain(graph.edge_maps[k])]}
      [200, {"Content-Type" => "text/html"}, [erb(:doc)]]
    end
    get "/" do
      @catalogue = params["catalogue"] || "ROOT"
      @catalogues = Mappum.catalogues
      @bidi_maps_name_source = Mappum.catalogue(@catalogue).list_bidi_map_names.collect{|mn| [mn,  Mappum.catalogue(@catalogue).get_bidi_map(mn).source] }
      @maps_name_source = Mappum.catalogue(@catalogue).list_map_names.collect{|mn| [mn, Mappum.catalogue(@catalogue)[mn].source]}
      [200, {"Content-Type" => "text/html"}, [erb(:main)]]
    end
    error do
      @xml_convertor = Syntax::Convertors::HTML.for_syntax "xml"
      @exception = request.env['sinatra.error']
      erb(:error)
    end

    def self.parseopt
      require 'optparse'
      OptionParser.new { |op|
        op.on('-x')        {       set :lock, true }
        op.on('-e env')    { |val| set :environment, val.to_sym }
        op.on('-s server') { |val| set :server, val }
        op.on('-p port')   { |val| set :port, val.to_i }
      }.parse!
    end
  end
end
if File.basename($0) == File.basename(__FILE__)
    Mappum::Mapserver.parseopt
    Mappum::Mapserver.run!
end
