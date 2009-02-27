require 'xsd/mapping'
require 'sample/client.rb'

module SampleClientMappingRegistry
  Registry = ::SOAP::Mapping::LiteralRegistry.new

  Registry.register(
    :class => Client,
    :schema_name => XSD::QName.new(nil, "client"),
    :schema_element => [
      ["title", "SOAP::SOAPString"],
      ["id", "SOAP::SOAPString", [0, 1]],
      ["first_name", "SOAP::SOAPString", [0, 1]],
      ["surname", "SOAP::SOAPString", [0, 1]],
      ["sex_id", "SOAP::SOAPString", [0, 1]],
      ["phones", "SOAP::SOAPString[]", [0, 20]],
      ["emails", "SOAP::SOAPString[]", [0, 3]],
      ["main_phone", "SOAP::SOAPString[]", [0, 3]],
      ["main_phone_type", "SOAP::SOAPString[]", [0, 3]],
      ["address", "Client::Address", [0, 1]]
    ]
  )

  Registry.register(
    :class => Client::Address,
    :schema_name => XSD::QName.new(nil, "address"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["street", "SOAP::SOAPString"],
      ["city", "SOAP::SOAPString", [0, 1]]
    ]
  )
end
