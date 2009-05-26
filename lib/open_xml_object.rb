class SOAP::Mapping::Object
  def id
    self[XSD::QName.new(nil, "id")]
  end
  def type
    self[XSD::QName.new(nil, "type")]
  end
end

class OpenXmlObject < SOAP::Mapping::Object
  def method_missing(sym, *args, &block)
    if sym.to_s.end_with?("=")
       __add_xmlele_from_method(sym.to_s[0..-2],args[0])        
    else  
      super(sym, *args, &block)
    end
  end
  def id=(value)
    __add_xmlele_from_method("id",value)        
  end
  def type=(value)
    __add_xmlele_from_method("type",value)        
  end
  private
  def __add_xmlele_from_method(name,value)
    Thread.current[:SOAPMapping] ||= {}
    Thread.current[:SOAPMapping][:SafeMethodName] ||= {}
    __add_xmlele_value(XSD::QName.new(nil, name),value)
  end
end 