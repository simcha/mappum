require 'sample/person_mapping_registry.rb'

class SamplePersonMapper < XSD::Mapping::Mapper
  def initialize
    super(SamplePersonMappingRegistry::Registry)
  end
end
