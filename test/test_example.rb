$:.unshift File.join(File.dirname(__FILE__),'..','lib')
#TODO fix imports
require 'mappum/ruby_transform'
require 'test/unit'
require 'sample/example_map'

Group = Struct.new(:main, :list)
ClientList = Struct.new(:leader, :clients)

class TestExample < Test::Unit::TestCase
  def stest_map
    catalogue = Mappum.catalogue("CRM-ERP")

    main_map = catalogue[ERP::Person]

    assert_equal(ERP::Person, main_map.from.clazz)
    assert_equal(CRM::Client, main_map.to.clazz)
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
    
    main_map = catalogue[CRM::Client]

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
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)
    
    per = ERP::Person.new
    per.title = "sir"
    per.type = "NaN"
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
    per.corporation = "Corporation l.t.d."
    per.date_updated = Date.today
    per.spouse = ERP::Person.new
    per.spouse.name = "Linda"
    
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
    assert_equal("Last", cli.order_by)
    assert_equal("Linda", cli.partners[0].name)
    assert_equal("Linda", cli.partners[1].name)
    assert(cli.updated.kind_of?(Time))
    
    
    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
  def stest_transform_nil_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = ERP::Person.new
    per.title = "sir"
    per.type = "NaN"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = ERP::Address.new
    per.address.street = "Victoria"
    per.date_updated = Date.today


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
  def stest_transform_funny_array
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = ERP::Person.new
    per.type = "NaN"
    per.email1 = "j@j.com"
    per.email3 = "l@l.com"
    per.main_phone = ERP::Phone.new("7869876")
    per.date_updated = Date.today
    
    cli = rt.transform(per)
    
    assert_equal(["j@j.com", nil, "l@l.com"], cli.emails)

    per2 = rt.transform(cli)
    assert_equal(per, per2)
  end
  def test_submaps
    catalogue = Mappum.catalogue("CRM-ERP")
    rt = Mappum::RubyTransform.new(catalogue)

    per = ERP::Person.new
    per.title = "sir"
    per.type = "NaN"
    per.person_id = "asddsa"
    per.sex = "M"
    per.name = "Skory"
    per.address = ERP::Address.new
    per.address.street = "Victoria"
    per.date_updated = Date.today

    group = Group.new
    group.main = per
    group.list = [per]
    #clilist =  ClientList.new
    puts clilist = rt.transform(group,catalogue[:Group])
    cli = clilist.clients[0]
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(CRM::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_nil(cli.phones)
    assert_nil(cli.main_phone)
    
    cli1 = clilist.leader
    assert_equal("sir", cli1.title)
    assert_equal("ASDDSA", cli1.id)
    assert_equal("2", cli1.sex_id)
  end
end
