require 'sample/person_mapping_registry'

class SamplePersonMapper < XSD::Mapping::Mapper
  def initialize
    super(SamplePersonMappingRegistry::Registry)
  end
end
