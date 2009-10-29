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
    
    protected
    
    def convert_to (to, field_def)
      if to.kind_of? Array then
        jtype = field_def.clazz
        jtype ||= "String"
        return to.to_java(jtype)
      else 
        return to
      end
    end
    def convert_from (from, field_def)
        if from.kind_of? ArrayJavaProxy then
          return from.to_ary
        else 
          return from
        end
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
