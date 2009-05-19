require 'xsd/mapping'
require 'sample/person'

module SamplePersonMappingRegistry
  Registry = ::SOAP::Mapping::LiteralRegistry.new

  Registry.register(
    :class => Phone,
    :schema_type => XSD::QName.new(nil, "phone"),
    :schema_element => [
      ["number", "SOAP::SOAPString"],
      ["extension", "SOAP::SOAPString", [0, 1]],
      ["type", "SOAP::SOAPString", [0, 1]]
    ]
  )

  Registry.register(
    :class => Person,
    :schema_name => XSD::QName.new(nil, "person"),
    :schema_element => [
      ["title", "SOAP::SOAPString"],
      ["person_id", "SOAP::SOAPString", [0, 1]],
      ["name", "SOAP::SOAPString", [0, 1]],
      ["surname", "SOAP::SOAPString", [0, 1]],
      ["sex", "SOAP::SOAPString", [0, 1]],
      ["email1", "SOAP::SOAPString", [0, 1]],
      ["email2", "SOAP::SOAPString", [0, 1]],
      ["email3", "SOAP::SOAPString", [0, 1]],
      ["main_phone", "Phone", [0, 1]],
      ["address", "Person::Address", [0, 1]],
      ["phones", "Phone[]", [0, 5]]
    ]
  )

  Registry.register(
    :class => Person::Address,
    :schema_name => XSD::QName.new(nil, "address"),
    :is_anonymous => true,
    :schema_qualified => false,
    :schema_element => [
      ["street", "SOAP::SOAPString"],
      ["city", "SOAP::SOAPString", [0, 1]]
    ]
  )
end
