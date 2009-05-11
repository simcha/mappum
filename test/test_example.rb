$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'ruby_transform'
require 'test/unit'
require 'sample/example_map'
require 'sample/erp'
require 'sample/crm'

class TestExample < Test::Unit::TestCase
  def test_map
    
    main_map = CrmErpMap[ERP::Person]

    assert_equal(ERP::Person.name.to_sym, main_map.from.clazz)
    assert_equal(CRM::Client.name.to_sym, main_map.to.clazz)
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
    
    main_map = CrmErpMap[CRM::Client]
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
    rt = Mappum::RubyTransform.new(CrmErpMap)
    
    per = ERP::Person.new
    per.title = "sir"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = ERP::Address.new
    per.address.street = "Victoria"
    per.email1 = "j@j.com"
    per.email2 = "k@k.com"
    per.email3 = "l@l.com"
    per.phones = [ERP::Phone.new("21311231"), ERP::Phone.new("21311232")]
    per.main_phone = ERP::Phone.new
    per.main_phone.number ="09876567"
    per.main_phone.type = :mobile

    cli = rt.transform(per)
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(CRM::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_equal(["j@j.com", "k@k.com", "l@l.com"], cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)

    per2 = rt.transform(cli)
    assert_equal(per, per2)


  end
  def test_transform_nil_array
    rt = Mappum::RubyTransform.new(CrmErpMap)

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
    rt = Mappum::RubyTransform.new(CrmErpMap)

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
