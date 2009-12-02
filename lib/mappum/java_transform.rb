require 'mappum/ruby_transform'
require 'mappum/xml_transform'
require 'java'

module Mappum
  #
  # Java Pojo to Pojo transforming class. Requires JRuby to work correctly.
  #
  class JavaTransform < RubyTransform
    def initialize(*args)
      super(*args)
    end
    def transform(from, map=nil, to=nil, options={})
      begin
        if map.kind_of?(Java::JavaUtil::Map)
          options = map
          map = nil
        end
        super(from, map, to, options) 
      rescue MappumException => me
        jme = Java::pl::ivmx::mappum::JavaMappumException.new(me)
        jme.from_name = me.from_name 
        jme.to_name = me.to_name 
        jme.from = me.from
        jme.to = me.to
        jme.from_root = me.from_root
        jme.to_root = me.to_root 
        jme.mappum_backtrace = me.mappum_backtrace
        
        raise jme
      end
    end
    protected
    def is_array?(obj)
      return (obj.kind_of?(Array) or obj.kind_of?(ArrayJavaProxy) or obj.kind_of?(Set) or obj.kind_of?(Java::JavaUtil::Set))
    end
    
    def convert_to (to, field_def, parent)
      if to.kind_of? Array or to.kind_of? Hash or to.kind_of? Set then
        param_type = nil
        unless parent.nil?
          jclass = parent.java_class
          unless jclass.nil?
            jmethod = jclass.declared_method_smart "set#{classify(field_def.name.to_s)}".to_sym
            param_type = jmethod.parameter_types[0]
          end
        end
        if (param_type.nil? and to.kind_of? Array) or (not param_type.nil? and param_type.array?)
          jtype = field_def.clazz
          jtype ||= "String"
          return to.to_java(jtype)
        elsif (param_type.nil? and to.kind_of? Set) or (not param_type.nil? and param_type <= java.util.Set.java_class)
          jset = java.util.LinkedHashSet.new to
          unless param_type.class.kind_of? Module
            jset = param_type.new to
          end
          return jset
        elsif (param_type.nil? and to.kind_of? Hash) or (not param_type.nil? and param_type <= java.util.Map.java_class)
          jmap = java.util.LinkedHashMap.new
          unless param_type.class.kind_of? Module
            jmap = param_type.new
          end
          jmap.put_all to
          return jmap
        else
          raise "#{param_type} of enumerable not supported"
        end
      else
        return to
      end
    end
    def convert_from (from, field_def)
        if from.kind_of?(ArrayJavaProxy) then
          return from.to_ary
        elsif from.kind_of?(Java::JavaUtil::Set) then 
           return from.to_a
        else
          return from
        end
    end
    private
    def classify(string)
      return string.gsub(/(^|_)(.)/) { $2.upcase }
    end
  end
  class JavaApi < Java::pl.ivmx.mappum.MappumApi
    def initialize
      super(false)
    end
    def getWorkdirLoader(schema_path="schema", map_dir="map", basedir=nil)
      return WorkdirLoader.new(schema_path, map_dir, basedir)
    end
    def getJavaTransform(catalogueName=nil)
      catalogue = Mappum.catalogue(catalogueName)
      return JavaTransform.new(catalogue)
    end
    def loadMaps(dir="map",reload=true)
      Mappum.drop_all
      JavaSupport.list_maps_on_cp(dir).each do |map_file|
        Mappum.source = map_file
        load map_file
        Mappum.source = nil
      end
    end
    def startServer
      require 'webrick'
      load 'mappum/mapserver/mapserver.rb'
      Mappum::Mapserver.parseopt
      Mappum::Mapserver.run!

    end
  end

  #
  # Utility class providing some usefull methods in java.
  #
  class JavaSupport
    #
    # List map files on classpath.
    #
    def self.list_maps_on_cp(dir="map")
      dir="map" if dir.nil?
      thread = java.lang.Thread.new
      class_loader = thread.context_class_loader
      container_urls = class_loader.find_resources(dir).to_a
      maplist = []
      container_urls.each do |url|
        if url.protocol == "file"
          filelist = Dir.glob(File.join(url.path,"*.rb"))
          #make paths relative again
          maplist += filelist.collect{|f| f[(url.path.size-dir.size)..-1]}
        elsif url.protocol ==  "vfsfile"
          filelist = Dir.glob(File.join(url.path,"*.rb"))
          #make paths relative again
          maplist += filelist.collect{|f| f[(url.path.size-dir.size-1)..-1]}
        elsif url.protocol == "jar"
          #beware nestet url
          path = URI.new(url.path).path
          path = path[0..(path.rindex("!")-1)]
          zip = java.util.zip.ZipFile.new(path)
          names = zip.entries.to_a.collect{|ze| ze.name}
          maplist += names.select{|nm| nm.index("map") == 0 and nm[-3..-1] == ".rb"}
        else
          #ups
          puts "WARN: Unknown protocol #{url.protocol} on the classpath. When looking for #{dir} in #{__FILE__}"
        end
      end
      return maplist
    end
  end
  class JavaTransform
    include Java::pl.ivmx.mappum.JavaTransform
  end
  class WorkdirLoader
    include Java::pl.ivmx.mappum.WorkdirLoader
  end
  class TreeElement
    include Java::pl.ivmx.mappum.TreeElement
  end
end
