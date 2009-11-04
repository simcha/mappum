# TODO docs
require 'set'
require 'mappum/dsl'
require 'mappum/map'

module Mappum
  #
  # Add mapinng in DSL to the catalogue.
  #
  def self.catalogue_add(name = "ROOT", &block)
    @catalogue ||= {}
    @catalogue_src ||= {}
    @catalogue[name] ||= RootMap.new(name)
    definition = DSL::RootMap.new(name, @source).make_definition(&block)
    definition.maps.each{|m| @catalogue[name].add(m)}
    definition.bidi_maps.each{|m| @catalogue[name].add(m)}
  end
  #
  # Get root map.
  #
  def self.catalogue(name = "ROOT")
    name = "ROOT" if name.nil?
    if @catalogue.nil?
      throw RuntimeError.new("No maps where loaded remember to put some moaps in 'map' folder and load them.\n"+
        "To load in ruby just require files or use WorkdirLoader.generate_and_require.\n"+
        "To load in java run:\nMappumApi mp = new MappumApi();\nmp.loadMaps();") 
    end
    @catalogue[name]
  end
  def self.catalogues
    return @catalogue.keys
  end
  #
  # Empty catalogues
  #
  def self.drop_all
    @catalogue = {}
    @catalogue_src = {}
  end
  #
  #Set source file from which definitions are read
  #
  def self.source=(src)
    @source = src
  end
end
