$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'xml_transform'
require 'test/unit'
require 'sample/example_notypes'
require 'rubygems'
gem 'builder'
require 'builder'
require 'xml'


class TestLibXML < Test::Unit::TestCase
  def test_transform
    catalogue = Mappum.catalogue("CRM-ERP")

    builder = Builder::XmlMarkup.new
    doc = builder.person do |per|
    per.title "sir"
    per.person_id "asddsa"
    per.sex "M"
    per.name "Skory"
    per.address {|a|
      a.street "Victoria"
      a.email1 "j@j.com"
      a.email2 "k@k.com"
      a.email3 "l@l.com"
    }
    #phone1 Mappum::OpenStruct.new
    #phone1.number="21311231"

    #phone2 Mappum::OpenStruct.new
    #phone2.number="21311232"

    #per.phones [phone1, phone2]
    per.main_phone { |mp|
      mp.number  "09876567"
      mp.type "mobile"
    }
  end
    rt = Mappum::XmlTransform.new(catalogue)
    
    cli = rt.transform(doc,catalogue[:person])
    puts cli
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

    per2 = rt.transform(cli,catalogue[:client])
    assert_equal(per, per2)


  end
  def test_transform_nil_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = Mappum::OpenStruct.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = Mappum::OpenStruct.new
    per.address.street = "Victoria"



    cli = rt.transform(per,catalogue[:person])
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_nil(cli.phones)
    assert_nil(cli.main_phone)

    per2 = rt.transform(cli,catalogue[:client])
    assert_equal(per, per2)
  end
  def test_transform_funny_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = Mappum::OpenStruct.new
    per.email1 = "j@j.com"
    per.email3 = "l@l.com"
    per.main_phone = Mappum::OpenStruct.new
    per.main_phone.number ="09876567"

    cli = rt.transform(per,catalogue[:person])
    assert_equal(["j@j.com", nil, "l@l.com"], cli.emails)

    per2 = rt.transform(cli,catalogue[:client])
    assert_equal(per, per2)
  end
end
