$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'xml_transform'
require 'test/unit'
require 'rubygems'
gem 'soap4r'
gem 'facets'
require 'facets/equatable'
require 'soap/marshal'
require 'sample/person_mapper'
require 'sample/client_mapper'
require 'sample/example_soap4r'

class Person
  include Equatable(:title, :person_id, :name, :surname, :sex, :email1, 
    :email2, :email3, :main_phone, :address, :phones)
end
class Phone
  include Equatable(:number, :extension, :type)
end
class Person::Address
  include Equatable(:city, :street)
end

class TestExample < Test::Unit::TestCase
  def test_xml_transform

    xml = IO.read("sample/person_fixture.xml")

    rt = Mappum::XmlTransform.new
        
    xml_cli = rt.transform(xml)

    xml2 = rt.transform(xml_cli)

    assert_equal(xml.strip, xml2.strip)


  end
  def test_transform
    catalogue = Mappum.catalogue
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
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)

    per = Person.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = Person::Address.new
    per.address.street = "Victoria"



    cli = rt.transform(per)
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(Client::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    # TODO fix [] issue in soap
    # assert_nil(cli.phones)
    # assert_nil(cli.main_phone)
    per2 = rt.transform(cli)
    
    assert_equal(per, per2)
  end
  def test_transform_funny_array
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)

    per = Person.new
    per.email1 = "j@j.com"
    per.email3 = "l@l.com"
    per.main_phone = Phone.new("7869876")
    cli = rt.transform(per)
    assert_equal(["j@j.com", nil, "l@l.com"], cli.emails)

    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
end
