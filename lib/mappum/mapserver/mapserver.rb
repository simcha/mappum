require 'rubygems'
gem 'soap4r'
require 'mappum/xml_transform'
require 'soap/marshal'
require 'mappum/mapserver/mapgraph'
require 'sinatra/base'
require 'erb'

module Mappum
  class Mapserver < Sinatra::Default
    set :views => File.join(File.dirname(__FILE__), 'views')
    configure do
      set :schema_dir => 'schema', :map_dir => 'map', :tmp_dir => nil
      set :catalogue => nil
      set :port => 9292      

      # FIXME make configurable
      #wl = Mappum::WorkdirLoader.new(options.schema_dir, options.tmp_dir, options.map_dir)
      wl = Mappum::WorkdirLoader.new('schema', nil, "map")
      wl.generate_and_require
    end
    helpers do
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
    
    post "/transform" do
          map_name = nil
          map_name = params["map"] unless params["map"].nil? or params["map"] == "auto_select"
          
          rt = Mappum::XmlTransform.new(options.catalogue)
          
          xml = params["doc"]
          content = rt.transform(xml,map_name)
          
          [200, {"Content-Type" => "text/xml"}, [content]]
    end
    post "/transform-ws" do
      map_name = nil
      map_name = params["SOAP_ACTION"] unless params["SOAP_ACTION"].nil? or params["SOAP_ACTION"] == ""
      
      rt = Mappum::XmlTransform.new(options.catalogue)
      
      xml = env["rack.input"].read
      start_time = Time.now


      content = rt.transform(xml,map_name)
      end_time = Time.now
      puts end_time - start_time           
      [200, {"Content-Type" => "text/xml"}, [content]]
    end
    get "/transform-ws.wsdl" do
      @xml_imports = {
        "file:///home/jtopinski/mapping/mappum/sample/server/schema/erp/erp_person.xsd" =>
          "http://mappum.ivmx.pl/person",
        "file:///home/jtopinski/mapping/mappum/sample/server/schema/crm_client.xsd" =>
          "http://mappum.ivmx.pl/client",
      }
      @xml_maps = []
      @xml_elements = Set.new
      Mappum.catalogue(options.catalogue).list_map_names.each do |mapname|
        map = Mappum.catalogue(options.catalogue)[mapname]
        
        from_qname = XSD::Mapping::Mapper.get_qname_from_class(map.from.clazz)
        @xml_elements << from_qname unless from_qname.nil?
        from_qname ||= XSD::QName.new(nil,"any")
        
        
        to_qname = XSD::Mapping::Mapper.get_qname_from_class(map.to.clazz)
        @xml_elements << to_qname unless to_qname.nil?
        to_qname ||= XSD::QName.new(nil,"any")
        
        @xml_maps << [mapname, from_qname, to_qname]
      end
      
      [200, {"Content-Type" => "text/xml"}, [erb(:'transform-ws.wsdl')]]    end

    get "/svggraph" do
      map_name = params["map"]
      map = Mappum.catalogue(options.catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(options.catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map " + map_name]] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/svg+xml"}, [graph.getSvg]]
            
    end
    get "/pnggraph" do
          map_name = params["map"]
          map = Mappum.catalogue(options.catalogue).get_bidi_map(map_name)
          map ||= Mappum.catalogue(options.catalogue)[map_name]
          return [404,  {"Content-Type" => "text/html"}, ["No map '#{map_name}'"]] if map.nil?
          graph = Mappum::MapServer::Graph.new(map)
          [200, {"Content-Type" => "image/png"}, graph.getPng]
            
    end 
    get "/doc" do
          map_name = params["map"]
          map = Mappum.catalogue(options.catalogue).get_bidi_map(map_name)
          map ||= Mappum.catalogue(options.catalogue)[map_name]
          return [404,  {"Content-Type" => "text/html"}, ["No map " + map_name]] if map.nil?
          graph = Mappum::MapServer::Graph.new(map)
          text = <<HTML
          <body>
            <h1>#{map_name}</h1>
            <p>
            #{map.desc}
            </p>
            <object type="image/svg+xml" data="/svggraph?map=#{map_name}"><img src="/pnggraph?map=#{map_name}"></object>
            <table border="1" cellspacing="0">
            <tr><td>Number</td><td>Description</td><td>Technical explanation</td></tr>
            #{graph.edge_maps.keys.sort.collect{|k| "<tr><td>#{k}</td><td>#{graph.edge_maps[k].desc}&nbsp;</td><td>#{explain(graph.edge_maps[k])}&nbsp;</td></tr>"}}
            </table>
          </body>
HTML
          [200, {"Content-Type" => "text/html"}, [text]]
    end
    get "/" do
          content404 = <<HTML
          <body>
          <FORM action="transform" method="post">
             <P>
            <select name="map">
              <option value="auto_select" selected="true">auto select</option>
              #{Mappum.catalogue(options.catalogue).list_map_names.collect{|mn| "<option value='#{mn}'>#{mn}</option>"}}
            </select>
            <br/>
             <TEXTAREA name="doc" rows="20" cols="80"></TEXTAREA><br/>
             <INPUT type="submit" value="Send"/><INPUT type="reset"/>
             </P>
          </FORM>
          <BR/>
          Bidirectional maps:<p>
          #{Mappum.catalogue(options.catalogue).list_bidi_map_names.collect{|mn| "<a href='/doc?map=#{mn}'>#{mn}</a><br/>"}}
          </p>
          <BR/>
          Unidirectional maps:<p>
          #{Mappum.catalogue(options.catalogue).list_map_names.collect{|mn| "<a href='/doc?map=#{mn}'>#{mn}</a><br/>"}}
          </p>     </body>
HTML
          [200, {"Content-Type" => "text/html"}, [content404]]
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
