class SOAP::Mapping::Object
  def id
    self[XSD::QName.new(nil, "id")]
  end
  def type
    self[XSD::QName.new(nil, "type")]
  end
  
  # 
  # XmlAny element is equal to the other xmlAny element when it 
  # has same elements and attributes regardles of ordering of 
  # elements and attributes.
  #
  def == other
    return false if other.class != self.class  
    return false if @__xmlele - other.__xmlele == []
    return false if @__xmlattr != other.__xmlattr
    return true
  end
end

class OpenXmlObject < SOAP::Mapping::Object
  def method_missing(sym, *args, &block)
    
    safename = XSD::CodeGen::GenSupport.safemethodname(sym.to_s).to_sym
    
    if safename != sym and self.respond_to?(safename)
      return self.send(safename, *args, &block)
    end
    
    if sym.to_s[-1..-1] == "=" then
      if sym.to_s[0..7] == "xmlattr_"
        #attribute
        name = sym.to_s[8..-2]
        __add_xmlattr_from_method(name, args[0])
      else
        #element
        __add_xmlele_from_method(sym.to_s[0..-2], args[0])
      end        
    else  
      super(sym, *args, &block)
    end
  end
  def id=(value)
    __add_xmlele_from_method("id", value)        
  end
  def type=(value)
    __add_xmlele_from_method("type",value)        
  end
  private
  def __add_xmlattr_from_method(name, value)
    @__xmlattr[XSD::QName.new(nil, name)] = value
    self.instance_eval <<-EOS
      def xmlattr_#{name}
        @__xmlattr[XSD::QName.new(nil, '#{name}')]
      end

      def xmlattr_#{name}=(value)
        @__xmlattr[XSD::QName.new(nil, '#{name}')] = value
      end
    EOS
  end
  def __add_xmlele_from_method(name, value)
    Thread.current[:SOAPMapping] ||= {}
    Thread.current[:SOAPMapping][:SafeMethodName] ||= {}
    __add_xmlele_value(XSD::QName.new(nil, name),value)
  end
end 