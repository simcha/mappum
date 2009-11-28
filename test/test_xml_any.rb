$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'mappum/xml_transform'
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
    xml = IO.read("sample/person_fixture_any.xml")
    client_xml =  rt.transform(xml, :notype_person_to_client)

    reg = ::SOAP::Mapping::LiteralRegistry.new()
    
    cli =  XSD::Mapping::Mapper.new(reg).xml2obj(client_xml)

    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal("j@j.com", cli.emails.m_0)
    assert_equal("k@k.com", cli.emails.m_1)
    assert_equal("l@l.com", cli.emails.m_2)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)
    assert_equal({XSD::QName.new(nil,"ident") => "123212"}, cli.__xmlattr)
    
    person2_xml =  rt.transform(client_xml, :client)
    person =  XSD::Mapping::Mapper.new(reg).xml2obj(xml)
    person2 =  XSD::Mapping::Mapper.new(reg).xml2obj(person2_xml)
        
    assert_equal(person, person2)

  end
  def test_xml_any_map_name
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
    rt = Mappum::XmlTransform.new(catalogue)
    xml = IO.read("sample/person_fixture_any.xml")
    client_xml =  rt.transform(xml, :person)

    reg = ::SOAP::Mapping::LiteralRegistry.new()
    
    cli =  XSD::Mapping::Mapper.new(reg).xml2obj(client_xml)

    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal("j@j.com", cli.emails.m_0)
    assert_equal("k@k.com", cli.emails.m_1)
    assert_equal("l@l.com", cli.emails.m_2)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

  end
end
