require 'sample/client_mapping_registry.rb'

class SampleClientMapper < XSD::Mapping::Mapper
  def initialize
    super(SampleClientMappingRegistry::Registry)
  end
end
