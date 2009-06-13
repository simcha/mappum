# TODO docs
require 'set'
require 'mappum/dsl'
require 'mappum/map'

module Mappum
  def self.catalogue_add(name = "ROOT", &block)
    @catalogue ||= {}
    @catalogue[name] ||= RootMap.new(name)
    definition = DSL::RootMap.new(name).make_definition(&block)
    @catalogue[name].maps += definition.maps
    @catalogue[name].bidi_maps += definition.bidi_maps
      
  end
  def self.catalogue(name = "ROOT")
    name = "ROOT" if name.nil?
    @catalogue[name]
  end
end