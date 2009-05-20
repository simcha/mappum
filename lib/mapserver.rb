require 'rubygems'
gem 'rack'
require 'rack/request'
require 'rack/response'
gem 'soap4r'
require 'wsdl/xmlSchema/xsd2ruby'
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
      from = req.POST["from"]
      
      rt = Mappum::XmlTransform.new(@catalogue)
      
      xml = req.POST["doc"]
      qname = XSD::QName.new(nil,from) unless from.nil? or from == "auto_select"
      content = rt.transform(xml,qname)
      
      [200, {"Content-Type" => "text/xml"}, content]
    else
      content404 = <<HTML
      <body>
      <FORM action="transform" method="post">
         <P>
        <select name="from">
          <option value="auto_select" selected="true">auto select</option>
        </select>
        <select name="to">
          <option value="auto_select" selected="true">auto select</option>
        </select>
        <br/>
         <TEXTAREA name="doc" rows="20" cols="80"></TEXTAREA><br/>
         <INPUT type="submit" value="Send"/><INPUT type="reset"/>
         </P>
      </FORM>

      </body>
HTML
      [404, {"Content-Type" => "text/html"}, content404]
    end
  end
end

if $0 == __FILE__
  require 'rack'
  require 'rack/showexceptions'
  Rack::Handler::WEBrick.run \
    Rack::ShowExceptions.new(Rack::Lint.new(MapServlet.new)),
    :Port => 9292
end