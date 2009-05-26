require 'ruby_transform'
require 'rubygems'
gem 'soap4r'
require 'soap/marshal'
require 'xsd/mapping'
require 'wsdl/xmlSchema/xsd2ruby'
require 'open_xml_object'

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
    @@mapper_classes ||= []
    if @@mapper_classes.size > @@mappers.size
      @@mappers = @@mapper_classes.collect{|k|k.new()}
    end
    @@mappers
  end
end
  
module Mappum
  class XmlTransform
    def initialize(map_catalogue = nil)
      #choose parser
      begin
        gem 'libxml-ruby'
        require 'libxml'
        @parser = :libxml
      rescue Gem::LoadError
        require 'rexml/parsers/sax2parser'
        @parser = :rexml
      end
      @default_mapper =  XSD::Mapping::Mapper.new(SOAP::Mapping::LiteralRegistry.new)
      @ruby_transform = RubyTransform.new(map_catalogue, OpenXmlObject)
    end
    def transform(from_xml, map=nil, from_qname=nil, to_qname=nil)
      
      if from_qname.nil?
        from_qname = qname_from_root(from_xml)
      end
      
      from_mapper = XSD::Mapping::Mapper.find_mapper_for_type(from_qname)
      if from_mapper.nil?
         from_mapper = @default_mapper
      end
      map ||= @ruby_transform.map_catalogue[from_qname]
      map ||= @ruby_transform.map_catalogue[from_qname.name.to_sym]
      if not map.nil? and not map.kind_of?(Map)
        map = @ruby_transform.map_catalogue[map.to_sym]
      end
     
      parsed = from_mapper.xml2obj(from_xml)
      
      transformed = @ruby_transform.transform(parsed, map)
      
      to_mapper = XSD::Mapping::Mapper.find_mapper_for_class(transformed.class)
      if to_mapper.nil?
        to_mapper = @default_mapper
      end

      if transformed.kind_of?(OpenXmlObject) and to_qname.nil? and not map.nil?
        to = map.to
        if to.clazz.kind_of?(XSD::QName)
          to_qname = to.clazz
        else
          to_qname = XSD::QName.new(nil, to.clazz.to_s)
        end
      end
      
      to_xml = to_mapper.obj2xml(transformed,to_qname)
      return to_xml
    end
    private
    def qname_from_root(xml)
      return qname_from_root_libxml(xml) if @parser == :libxml
      return qname_from_root_rexml(xml)
    end
    def qname_from_root_rexml(from_xml)
      reader = REXML::Parsers::SAX2Parser.new(from_xml)
      retqname = nil
      #TODO optimize: quit after root
      reader.listen(:start_element) do |uri, localname, qname, attributes|
        retqname ||= XSD::QName.new(uri, localname)
      end

      reader.parse
      return retqname
    end
    def qname_from_root_libxml(from_xml)
      reader = LibXML::XML::Reader.string(from_xml)
      reader.read
      return XSD::QName.new(reader.namespace_uri, reader.name)
    end
  end
  # Class supporting loading working directory of the layout:
  #
  # schema/ - Directory containing xsd files
  #
  # map/ - directory containing Mappum maps
  #
  class WorkdirLoader
    def initialize(schema_path = "schema", basedir="tmp", map_dir="maps")
      @schema_path = schema_path
      @basedir = basedir
      @map_dir = map_dir
      @mapper_scripts = []
    end
    def generate_and_require
      generate_classes
      require_all
    end
    def require_all
      require_schemas
      require_maps
    end
    # Generate classes from xsd files in shema_path (defaults to schema).
    # Files containt in subdirectories are generated to modules where module name is
    # optaind from folder name.
    # Generated classes are saved to basedir (defaults to tmp)
    def generate_classes(schema_path=nil, module_path=nil)
      class_dir = @basedir
      modname = module_path
      unless module_path.nil?
        class_dir = File.join(class_dir, module_path) 
        modname = modname.gsub(File::SEPARATOR, "::")
        modname = modname.gsub(/^[a-z]|\s+[a-z]|\:\:+[a-z]/) { |a| a.upcase }
      end
      
      Dir.mkdir(class_dir) unless File.exist? class_dir
      

      
      schema_path ||= @schema_path 
      
      Dir.foreach(schema_path) do |file_name|
        full_name = File.join(schema_path,file_name)
        #when file is a directory
        #generate classes in module (recursive)
        if File.directory?(full_name) and not file_name == "." and not file_name == ".."
          #make directory for future class files
          module_pth = file_name
          module_pth = File.join(module_path, module_pth) unless module_path.nil?
           
          generate_classes(full_name, module_pth)
        # for XSD files generate classes using XSD2Ruby
        elsif /.*.xsd/ =~ file_name
          run_xsd2ruby(full_name, file_name, module_path, modname)
          @mapper_scripts <<  class_dir + File::SEPARATOR + file_name[0..-5] + "_mapper.rb"
        end
      end
    end
    def require_schemas
      $:.unshift @basedir
      @mapper_scripts.each do |script|
        require script
      end
    end
    def require_maps
      $:.unshift @map_dir
      Dir.foreach(@map_dir) do |file_name|
        if /.*.rb/ =~ file_name
          require File.join(@map_dir, file_name)
        end
      end
    end
    private 
    def run_xsd2ruby(full_name, file_name, module_path, modname)
      worker = WSDL::XMLSchema::XSD2Ruby.new
      worker.location = full_name
      worker.basedir = @basedir
      
      classdef = file_name[0..-5]
      classdef = File.join(module_path,classdef) unless module_path.nil?
      
      opt = {"classdef" => classdef, "mapping_registry"  => "", "mapper" => "", "force" => ""}
      opt["module_path"] = modname unless modname.nil?
      worker.opt.update(opt)
      worker.run
    end
  end
end