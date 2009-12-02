$:.unshift File.join(File.dirname(__FILE__),'..','lib')
require 'mappum/ruby_transform'
require 'test/unit'
require 'sample/example_context'

class Context < Struct.new(:properties, :session)
end

class TestExample < Test::Unit::TestCase
  def test_transform
    catalogue = Mappum.catalogue("Context")
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
    ctx = Context.new
    ctx.properties={:title => "sir", :id => "asDDsa"}
    
    cli = rt.transform(per,nil,nil,{:context => ctx})
    
    assert_equal("sir", ctx.properties[:new_title])
    assert_equal("sir", cli.title)
    assert_equal("ASDDSA", cli.id)
    assert_equal("2", cli.sex_id)
    assert_equal("Skoryski", cli.surname)
    assert_equal(CRM::Address, cli.address.class)
    assert_equal("Victoria", cli.address.street)
    assert_equal({0=>"j@j.com", 1=>"k@k.com", 2=>"l@l.com"}, cli.emails)
    assert_equal(["21311231", "21311232"], cli.phones)
    assert_equal("09876567", cli.main_phone)
    assert_equal("Last", cli.order_by)
    assert_equal("Linda", cli.partners[0].name)
    assert_equal("Wife", cli.partners[0].type)
    assert_equal("Linda", cli.partners[1].name)
    assert_equal("Friend", cli.partners[1].type)
    assert(cli.updated.kind_of?(Time))
    
    per2 = rt.transform(cli,nil,nil,{:context => ctx})
    assert_equal(per, per2)
  end
end
