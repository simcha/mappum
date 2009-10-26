$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'mappum/xml_transform'
require 'test/unit'
require 'rubygems'
gem 'soap4r'
gem 'facets'
require 'facets/equatable'
require 'soap/marshal'

wl = Mappum::WorkdirLoader.new("sample/server/schema", "sample/server/map")
wl.generate_and_require   

class Erp::Person
  include Equatable(:title, :person_id, :name, :surname, :sex, :email1, 
    :email2, :email3, :main_phone, :address, :phones)
end
class Erp::Phone
  include Equatable(:number, :extension, :type)
end
class Erp::Person::Address
  include Equatable(:city, :street)
end

class TestExample < Test::Unit::TestCase
   def initialize(*args)
     super(*args)
     @rt = Mappum::XmlTransform.new
     @personMapper = Erp::ErpErp_personMapper.new
     @clientMapper = Crm_clientMapper.new
   end
  def test_xml_transform
    
    xml = IO.read("sample/person_fixture.xml")

    xml_cli = @rt.transform(xml)

    xml2 = @rt.transform(xml_cli)

    assert_equal(xml.strip, xml2.strip)

  end
  def test_transform
    
    xml = IO.read("sample/person_fixture.xml")
    clixml = @rt.transform(xml)
    cli = @clientMapper.xml2obj(clixml)
    
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(Client::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

    xml2 = @rt.transform(clixml)

    assert_equal(xml.strip, xml2.strip)


  end
  def test_transform_nil_array
 
    per = Erp::Person.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = Erp::Person::Address.new
    per.address.street = "Victoria"
    per.phones = nil
    
    perxml = @personMapper.obj2xml(per)
    clixml = @rt.transform(perxml)
    cli = @clientMapper.xml2obj(clixml)
    
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(Client::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_nil(cli.phones)
    assert_nil(cli.main_phone)
    per2xml = @rt.transform(clixml)
    
    per2 = @personMapper.xml2obj(per2xml)
    
    assert_equal(per, per2)
  end
  def test_transform_funny_array
    catalogue = Mappum.catalogue
    rt = Mappum::RubyTransform.new(catalogue)

    per = Erp::Person.new
    per.email1 = "j@j.com"
    per.email2 = "l@l.com"
    per.main_phone = Erp::Phone.new("7869876")
    cli = rt.transform(per)
    assert_equal(["j@j.com", "l@l.com", nil], cli.emails)

    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
end
