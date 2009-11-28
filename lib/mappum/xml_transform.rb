require 'mappum/ruby_transform'
require 'rubygems'
gem 'soap4r'
require 'soap/marshal'
require 'xsd/mapping'
require 'wsdl/xmlSchema/xsd2ruby'
require 'mappum/open_xml_object'
require 'tmpdir'
require 'fileutils'
      
module SOAP::Mapping::RegistrySupport
  def class_schema_definition
    @class_schema_definition
  end
  def class_elename_schema_definition
    @class_elename_schema_definition
  end
end

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
  def self.get_qname_from_class(klass)
    begin
      klass = const_get(klass) if klass.instance_of?(Symbol)
    rescue NameError
      return nil
    end
    ret_qname = nil
    #FIXME add cache
    mappers.each do |mapper|
      begin 
        sch = mapper.registry.schema_definition_from_class klass
        ret_qname =  sch.elename unless sch.nil?
      rescue NoMethodError
      end
    end
    return ret_qname
  
  end
  def self.get_class_from_qname(qname)
    mapper = find_mapper_for_type(qname)
    return nil if mapper.nil?
    sch =  mapper.registry.schema_definition_from_elename(qname)
    return sch.class_for
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
  def obj2soap(obj, elename = nil, io = nil)
    opt = MAPPING_OPT.dup
    unless elename
      if definition = @registry.elename_schema_definition_from_class(obj.class)
        elename = definition.elename
        opt[:root_type_hint] = false
      end
    end
    elename = SOAP::Mapping.to_qname(elename) if elename
    soap = SOAP::Mapping.obj2soap(obj, @registry, elename, opt)
    if soap.elename.nil? or soap.elename == XSD::QName::EMPTY
      soap.elename =
        XSD::QName.new(nil, SOAP::Mapping.name2elename(obj.class.to_s))
    end
    return soap
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
  #
  # SOAP4r based xml to xml transforming class.
  #
  class XmlTransform
    def initialize(map_catalogue = nil, force_open_struct=false)
      @default_mapper =  XSD::Mapping::Mapper.new(SOAP::Mapping::LiteralRegistry.new)
      @ruby_transform = RubyXmlTransform.new(map_catalogue, OpenXmlObject, force_open_struct)
    end
    #
    # Transforms given from_xml using map xml transformation from and to Ruby objects can
    # be controled via from_qname and to_qname. And soap envelope will be striped when handle_soap=true.
    #
    def transform(from_xml, map=nil, from_qname=nil, to_qname=nil, handle_soap=true)
      soap = false
      
      parser = SOAP::Parser.new(XSD::Mapping::Mapper::MAPPING_OPT)
      preparsed = parser.parse(from_xml)

      if from_qname.nil?
        from_qname = preparsed.elename
      end
      
      if handle_soap and from_qname == XSD::QName.new("http://schemas.xmlsoap.org/soap/envelope/","Envelope")
        soap = true
        #for soap remove envelope
        preparsed = preparsed.body.root_node
        from_qname = preparsed.elename
      end
      
            
      from_mapper = XSD::Mapping::Mapper.find_mapper_for_type(from_qname)
      
      if from_mapper.nil?
         from_mapper = @default_mapper
      end
     
      from_clazz = XSD::Mapping::Mapper.get_class_from_qname(from_qname) unless from_qname.nil?
      begin
        parsed =SOAP::Mapping.soap2obj(preparsed, from_mapper.registry, from_clazz)
      rescue NoMethodError => e
        raise ParsingFailedException.new("Parsing failed for xml with root element: #{from_qname}")
      end

      map ||= @ruby_transform.map_catalogue[from_qname]
      map ||= @ruby_transform.map_catalogue[from_qname.name.to_sym] unless from_qname.name.nil?
      if not map.nil? and not map.kind_of?(Map)
        map = @ruby_transform.map_catalogue[map.to_sym]
      end

      begin
        transformed = @ruby_transform.transform(parsed, map)
      rescue MapMissingException => e
        if e.from == parsed
          raise MapMissingException.new(e.from,"Map for element \"#{from_qname}\" not found!")
        else
          e.from = to_xml_string(e.from)
          e.to = to_xml_string(e.to)
          e.from_root = to_xml_string(e.from_root)
          e.to_root = to_xml_string(e.to_root)
          raise e
        end
      rescue MappumException => e
          e.from = to_xml_string(e.from)
          e.to = to_xml_string(e.to)
          e.from_root = to_xml_string(e.from_root)
          e.to_root = to_xml_string(e.to_root)
          raise e
      end
      
	  return to_xml_string(transformed, map, to_qname, soap)
    end
    def to_xml_string(transformed, map=nil, to_qname=nil, soap=false)
       to_mapper = XSD::Mapping::Mapper.find_mapper_for_class(transformed.class)
      if to_mapper.nil?
        to_mapper = @default_mapper
      end

      if transformed.kind_of?(OpenXmlObject) and to_qname.nil? and not map.nil?
        to = map.to
        if to.clazz.kind_of?(XSD::QName)
          to_qname = to.clazz
        else
          to_qname = XSD::QName.new(nil, XSD::CodeGen::GenSupport.safeconstname(to.clazz.to_s))
        end
      end
      to_preparsed = to_mapper.obj2soap(transformed,to_qname)
      if soap == true 
        to_preparsed = SOAP::SOAPEnvelope.new(SOAP::SOAPHeader.new, SOAP::SOAPBody.new(to_preparsed))
      end
      generator = SOAP::Generator.new(XSD::Mapping::Mapper::MAPPING_OPT)
      return generator.generate(to_preparsed, nil)
    end
  end
  class RubyXmlTransform < RubyTransform
    def initialize(*args)
      super(*args)
    end
    def get(object, field, parent_field=nil, options={})
      begin
        super(object, field, parent_field, options)
      rescue NoMethodError
        begin
          super(object, XSD::CodeGen::GenSupport.safemethodname(field.name.to_s).to_sym, parent_field, options)
        rescue NoMethodError
          #for dynamic xml nil value == no methond
          if object.kind_of?(SOAP::Mapping::Object)
            return nil
          else
            raise
          end
        end
      end
    end
  end
  class TreeElement < Struct.new(:name, :elements, :is_array, :clazz)
    include Comparable
    def <=>(anOther)
      return name <=> null if anOther.nil?
      name <=> anOther.name
    end
  end
  # Class supporting loading working directory of the layout:
  #
  # schema/ - Directory containing xsd files
  #
  # map/ - directory containing Mappum maps
  #
  class WorkdirLoader
    def initialize(schema_path = "schema", map_dir="map", basedir=nil)
      schema_path = "schema" if schema_path.nil?
      @schema_path = schema_path
      @basedir = basedir
      @basedir ||= mktmpdir
      map_dir = "map" if map_dir.nil?
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
        if File.directory?(full_name) and not file_name[0..0] == "." 
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
          Mappum.source = File.join(@map_dir, file_name)
          require File.join(@map_dir, file_name)
          Mappum.source = nil
        end
      end
    end
    #
    # Returns simple tree structure representing all elements defined in schemas
    #
    #
    def defined_element_trees(schema_definition = nil)
      returning = []
      if schema_definition == nil then
        XSD::Mapping::Mapper.mappers.each do |mapper|
           mapper.registry.class_schema_definition.each do |k,v|
             returning << defined_element_trees(v)
           end
        end
        return returning
      end
      name = schema_definition.varname if schema_definition.respond_to?(:varname)
      name ||= schema_definition.class_for
      is_array = false
      is_array = schema_definition.as_array? if schema_definition.respond_to?(:as_array?)

      subelems = nil
			mapped_class = schema_definition.mapped_class if schema_definition.respond_to?(:mapped_class)

      if schema_definition.respond_to?(:elements) and not schema_definition.elements.nil?
        subelems ||= []
        schema_definition.elements.each do |element|
          subelems << defined_element_trees(element)
        end
        mapped_class = nil
      end
			if schema_definition.respond_to?(:attributes) and not schema_definition.attributes.nil?
			      
			  subelems ||= []
			  schema_definition.attributes.each do |qname, type|
          subelems << TreeElement.new("xmlattr_#{qname.name}", nil,false,type)
        end
			end
			
			subelems.sort! unless subelems.nil?
			
      return TreeElement.new(name, subelems,is_array,mapped_class)
    end
    #
    # Remove tmpdir
    #
    def cleanup
      FileUtils.rm_rf(@basedir) if @cleanup
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
    def mktmpdir
      @cleanup = true
      prefix = "d"
      tmpdir ||= Dir.tmpdir
      t = Time.now.strftime("%Y%m%d")
      n = nil
      begin
        path = "#{tmpdir}/#{prefix}#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
        path << "-#{n}" if n
        Dir.mkdir(path, 0700)
      rescue Errno::EEXIST
        n ||= 0
        n += 1
        retry
      end
      return path      
    end
  end
  class XmlSupport
    #choose parser
    begin
      gem 'libxml-ruby'
      require 'libxml'
      @@parser = :libxml
    rescue Gem::LoadError
      require 'rexml/parsers/sax2parser'
      require 'rexml/element'
      @@parser = :rexml
    end
    #
    # Get target namespace from given xsd file
    #
    def self.get_target_ns(xsd_file)
      return get_target_ns_libxml(xsd_file) if @@parser == :libxml
      return get_target_ns_rexml(xsd_file)
    end
    def self.get_target_ns_rexml(xsd_file)
      reader = REXML::Parsers::SAX2Parser.new(File.new(xsd_file))
      namespace = nil
      #FIXME: quit after root
      reader.listen(:start_element) do |uri, localname, qname, attributes|
        namespace ||= attributes["targetNamespace"]
      end

      reader.parse
      return namespace
    end
    def self.get_target_ns_libxml(xsd_file)
      reader = LibXML::XML::Reader.file(xsd_file)
      reader.read
      reader.move_to_attribute("targetNamespace")
      namespace = reader.value
      reader.close
      return namespace 
    end
  end  
  class ParsingFailedException  < RuntimeError    
  end
end
