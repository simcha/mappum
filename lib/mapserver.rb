require 'rubygems'
gem 'rack'
require 'rack/request'
require 'rack/response'
gem 'soap4r'
require 'xml_transform'
require 'soap/marshal'


class MapServlet
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
      </body>
HTML
      [404, {"Content-Type" => "text/html"}, content404]
    end
  end
end

if File.basename($0) == File.basename(__FILE__)
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::WEBrick.run \
    Rack::ShowExceptions.new(Rack::Lint.new(MapServlet.new)),
    :Port => 9292
end
