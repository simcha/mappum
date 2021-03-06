$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'mappum/ruby_transform'
require 'test/unit'
require 'sample/example_notypes'

class TestOpenStruct < Test::Unit::TestCase
  def test_map
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")

    main_map = catalogue[:person]

    assert_equal(:person, main_map.from.clazz)
    assert_equal(:client, main_map.to.clazz)
    #assert_equal(5, main_map.maps.size)

    # check >>
    map_title = main_map.maps[0]
    assert_equal(:title, map_title.from.name)
    assert_equal(main_map.from, map_title.from.parent)
    assert_equal(:title, map_title.to.name)
    assert_equal(main_map.to, map_title.to.parent)

    # check >>
    map_title = main_map.maps[1]
    assert_equal(:person_id, map_title.from.name)
    assert_equal(main_map.from, map_title.from.parent)
    assert_equal(:id, map_title.to.name)
    assert_equal(main_map.to, map_title.to.parent)
    
    main_map = catalogue[:client]
    # check <<
    map_title = main_map.maps[0]
    assert_equal(:title, map_title.from.name)
    assert_equal(main_map.from, map_title.from.parent)
    assert_equal(:title, map_title.to.name)
    assert_equal(main_map.to, map_title.to.parent)

    # check <<
    map_title = main_map.maps[1]
    assert_equal(:id, map_title.from.name)
    assert_equal(main_map.from, map_title.from.parent)
    assert_equal(:person_id, map_title.to.name)
    assert_equal(main_map.to, map_title.to.parent)
  end
  def test_transform
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)
    
    per = Mappum::OpenStruct.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = Mappum::OpenStruct.new
    per.address.street = "Victoria"
    per.email1 = "j@j.com"
    per.email2 = "k@k.com"
    per.email3 = "l@l.com"
    
    phone1 = Mappum::OpenStruct.new
    phone1.number="21311231"

    phone2 = Mappum::OpenStruct.new
    phone2.number="21311232"
    
    per.phones = [phone1, phone2]
    per.main_phone = Mappum::OpenStruct.new
    per.main_phone.number ="09876567"
    per.main_phone.type = :mobile

    cli = rt.transform(per,catalogue[:person])
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal("Victoria", cli.address.street)
    assert_equal({0 => "j@j.com", 1 => "k@k.com", 2 => "l@l.com"}, cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

    per2 = rt.transform(cli,catalogue[:client])
    assert_equal(per, per2)


  end
  def test_transform_nil_array
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
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
    catalogue = Mappum.catalogue("NOTYPE-CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = Mappum::OpenStruct.new
    per.email1 = "j@j.com"
    per.email2 = "l@l.com"
    per.main_phone = Mappum::OpenStruct.new
    per.main_phone.number ="09876567"

    cli = rt.transform(per,catalogue[:person])
    assert_equal({0 => "j@j.com", 1 => "l@l.com", 2 =>  nil}, cli.emails)

    per2 = rt.transform(cli,catalogue[:client])
    assert_equal(per, per2)
  end
end
