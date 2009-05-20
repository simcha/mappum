require 'ruby_transform'
require 'rubygems'
gem 'soap4r'
require 'soap/marshal'
require 'xsd/mapping'
gem 'libxml-ruby'
require 'libxml'
class XSD::Mapping::Mapper
  attr_reader :registry
  def self.inherited(klass)
    @@mapper_classes ||= []
    @@mapper_classes << klass
  end
  def self.find_mapper_for_class(klass)
    klass = const_get(klass) if klass.instance_of?(Symbol)
    ret_maper=nil
    #FIXME add cache
    mappers.each do |mapper|
      begin 
        sch = mapper.registry.schema_definition_from_class klass
        ret_maper = mapper unless sch.nil?
      rescue NoMethodError
      end
    end
    return ret_maper
  end
  
  def self.find_mapper_for_type(qname)
    ret_maper=nil
    #FIXME add cache
    mappers.each do |mapper|
      begin 
        sch = mapper.registry.schema_definition_from_elename qname
        ret_maper = mapper unless sch.nil?
      rescue NoMethodError
      end
    end
    return ret_maper
  end
 private
  def self.mappers
    @@mappers ||= []
    if @@mapper_classes.size > @@mappers.size
      @@mappers = @@mapper_classes.collect{|k|k.new()}
    end
    @@mappers
  end
end
  
module Mappum
  class XmlTransform
    def initialize(map_catalogue = nil)
      @ruby_transform = RubyTransform.new(map_catalogue)
    end
    def transform(from_xml, from_qname=nil, map=nil)
      
      if from_qname.nil?
        from_qname = qname_from_root(from_xml)
      end
      
      from_mapper = XSD::Mapping::Mapper.find_mapper_for_type(from_qname)
      if from_mapper.nil?
        raise "QName \"#{from_qname}\" not registered for xml mapping. Missing require?"   
      end
       
      parsed = from_mapper.xml2obj(from_xml)
      
      transformed = @ruby_transform.transform(parsed)
      
      to_mapper = XSD::Mapping::Mapper.find_mapper_for_class(transformed.class)
      if from_mapper.nil?
        raise "Class \"#{transformed.class}\" not registered for xml mapping. Missing require?"   
      end     
      to_xml = to_mapper.obj2xml(transformed)
      return to_xml
    end
    private
    def qname_from_root(from_xml)
      reader = LibXML::XML::Reader.string(from_xml)
      reader.read
      return XSD::QName.new(reader.namespace_uri, reader.name)
    end
  end
end