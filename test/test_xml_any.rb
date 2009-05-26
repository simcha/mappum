$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'xml_transform'
require 'test/unit'
require 'rubygems'
gem 'soap4r'
gem 'facets'
require 'facets/equatable'
require 'soap/marshal'
require 'sample/example_notypes'

NsXMLSchema = "http://www.w3.org/2001/XMLSchema"
class TestXmlAny < Test::Unit::TestCase
  
  def test_xml_any
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
    rt = Mappum::XmlTransform.new(catalogue)
    xml = IO.read("sample/person_fixture.xml")
    client_xml =  rt.transform(xml)

    reg = ::SOAP::Mapping::LiteralRegistry.new()
    
    cli =  XSD::Mapping::Mapper.new(reg).xml2obj(client_xml)

    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

  end
  def test_xml_any_map_name
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
    rt = Mappum::XmlTransform.new(catalogue)
    xml = IO.read("sample/person_fixture.xml")
    client_xml =  rt.transform(xml, :person)

    reg = ::SOAP::Mapping::LiteralRegistry.new()
    
    cli =  XSD::Mapping::Mapper.new(reg).xml2obj(client_xml)

    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

  end
end
