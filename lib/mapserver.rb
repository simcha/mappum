require 'rubygems'
gem 'rack'
require 'rack/request'
require 'rack/response'
gem 'soap4r'
require 'xml_transform'
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
  def call(env)
    req = Rack::Request.new(env)
    if env["PATH_INFO"] == "/transform"
      map_name = nil
      map_name = req.POST["map"] unless req.POST["map"].nil? or req.POST["map"] == "auto_select"
      
      rt = Mappum::XmlTransform.new(@catalogue)
      
      xml = req.POST["doc"]
      content = rt.transform(xml,map_name)
      
      [200, {"Content-Type" => "text/xml"}, content]
    elsif env["PATH_INFO"] == "/svggraph"
      map_name = req.GET["map"]
      map = Mappum.catalogue(@catalogue).get_bidi_map(map_name)
      map ||= Mappum.catalogue(@catalogue)[map_name]
      return [404,  {"Content-Type" => "text/html"}, "No map " + map_name] if map.nil?
      graph = Mappum::MapServer::Graph.new(map)
      [200, {"Content-Type" => "image/svg+xml"}, graph.getSvg]
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
      #{Mappum.catalogue(@catalogue).list_bidi_map_names.collect{|mn| "<a href='/svggraph?map=#{mn}'>#{mn}</a><br/>"}}
      </p>
      <BR/>
      Unidirectional maps:<p>
      #{Mappum.catalogue(@catalogue).list_map_names.collect{|mn| "<a href='/svggraph?map=#{mn}'>#{mn}</a><br/>"}}
      </p>     </body>
HTML
      [404, {"Content-Type" => "text/html"}, content404]
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
