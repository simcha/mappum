require 'rubygems'
gem 'rack'
require 'rack/request'
require 'rack/response'
gem 'soap4r'
require 'mappum/xml_transform'
require 'soap/marshal'
require 'mapserver/mapgraph'

module Mappum
end
class Mappum::MapServlet
  def initialize(schema_path='schema', map_path='map', catalogue=nil)
    wl = Mappum::WorkdirLoader.new(schema_path, "tmp", map_path)
    wl.generate_and_require
    @catalogue = catalogue
  end
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
  def call(env)
    req = Rack::Request.new(env)
    if env["PATH_INFO"] == "/transform"
      map_name = nil
      map_name = req.POST["map"] unless req.POST["map"].nil? or req.POST["map"] == "auto_select"
      
      rt = Mappum::XmlTransform.new(@catalogue)
      
      xml = req.POST["doc"]
      content = rt.transform(xml,map_name)
      
      [200, {"Content-Type" => "text/xml"}, [content]]
    elsif env["PATH_INFO"] == "/transform_ws"
            map_name = nil
            map_name = req["SOAP_ACTION"] unless req["SOAP_ACTION"].nil? or req["SOAP_ACTION"] == ""
            
            rt = Mappum::XmlTransform.new(@catalogue)
            
            xml = env["rack.input"].read
      start_time = Time.now


            content = rt.transform(xml,map_name)
      end_time = Time.now
      puts end_time - start_time           
            [200, {"Content-Type" => "text/xml"}, [content]]
    elsif env["PATH_INFO"] == "/svggraph"
      map_name = req.GET["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map " + map_name]] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/svg+xml"}, [graph.getSvg]]
        
    elsif env["PATH_INFO"] == "/pnggraph"
      map_name = req.GET["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, ["No map '#{map_name}'"]] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/png"}, graph.getPng]
        
    elsif env["PATH_INFO"] == "/doc"
      map_name = req.GET["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
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
    else
      content404 = <<HTML
      <body>
      <FORM action="transform" method="post">
         <P>
        <select name="map">
          <option value="auto_select" selected="true">auto select</option>
          #{Mappum.catalogue(@catalogue).list_map_names.collect{|mn| "<option value='#{mn}'>#{mn}</option>"}}
        </select>
        <br/>
         <TEXTAREA name="doc" rows="20" cols="80"></TEXTAREA><br/>
         <INPUT type="submit" value="Send"/><INPUT type="reset"/>
         </P>
      </FORM>
      <BR/>
      Bidirectional maps:<p>
      #{Mappum.catalogue(@catalogue).list_bidi_map_names.collect{|mn| "<a href='/doc?map=#{mn}'>#{mn}</a><br/>"}}
      </p>
      <BR/>
      Unidirectional maps:<p>
      #{Mappum.catalogue(@catalogue).list_map_names.collect{|mn| "<a href='/doc?map=#{mn}'>#{mn}</a><br/>"}}
      </p>     </body>
HTML
      [404, {"Content-Type" => "text/html"}, [content404]]
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::WEBrick.run \
    Rack::ShowExceptions.new(Rack::Lint.new(Mappum::MapServlet.new)),
    :Port => 9292
end
