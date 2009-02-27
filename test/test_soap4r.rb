$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'ruby_transform'
require 'test/unit'
require 'rubygems'
gem 'soap4r'
require 'soap/marshal'
require 'sample/example_soap4r'
require 'sample/person_mapper'
require 'sample/client_mapper'

class TestExample < Test::Unit::TestCase
  def test_transform
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)
    personMapper = SamplePersonMapper.new
    
     xml = IO.read("sample/person_fixture.xml")
    parsed_person = personMapper.xml2obj(xml)

    cli = rt.transform(parsed_person)
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(Client::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

    per2 = rt.transform(cli)
    clientMapper = SampleClientMapper.new
    xml_cli = clientMapper.obj2xml(cli)
    xml2 = personMapper.obj2xml(per2)
    assert_equal(xml.strip, xml2.strip)


  end
  def test_transform_nil_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = ERP::Person.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = ERP::Address.new
    per.address.street = "Victoria"



    cli = rt.transform(per)
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(CRM::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_nil(cli.phones)
    assert_nil(cli.main_phone)

    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
  def test_transform_funny_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = ERP::Person.new
    per.email1 = "j@j.com"
    per.email3 = "l@l.com"
    per.main_phone = ERP::Phone.new("7869876")
    cli = rt.transform(per)
    assert_equal(["j@j.com", nil, "l@l.com"], cli.emails)

    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
end
