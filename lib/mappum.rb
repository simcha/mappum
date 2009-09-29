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
    @catalogue[name].maps += definition.maps
    @catalogue[name].bidi_maps += definition.bidi_maps
  end
  #
  # Get root map.
  #
  def self.catalogue(name = "ROOT")
    name = "ROOT" if name.nil?
    @catalogue[name]
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
