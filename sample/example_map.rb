# Example of map for given object domains CRM and ERP
require 'mappum'
require 'sample/erp'
require 'sample/crm'
require 'date'

Mappum.catalogue_add "CRM-ERP" do

  map ERP::Person, CRM::Client do |p, c|

    `simple mapping`
    map p.title <=> c.title

    `map with simple function call`
    map p.person_id << c.id.downcase
    map p.person_id.upcase >> c.id
    
    `dictionary use`
    map p.sex <=> c.sex_id, :dict => {"F" => "1", "M" => "2"}

    `submaps`
    map p.address(ERP::Address) <=> c.address(CRM::Address) do |a, b|
      map a.street <=> b.street
      #etc.
    end

    `compicated finc call`
    map p.name >> c.surname do |name|
      name + "ski"
    end
    map p.name << c.surname do |name|
      if name =~ /ski/
        name[0..-4]
      else
        name
      end
    end
    `field to hash and hash to field`
    map p.email1 <=> c.emails[0]
    map p.email2 <=> c.emails[1]
    map p.email3 <=> c.emails[2]
    
    map p.spouse(ERP::Person) <=> c.partners.find{|cp|cp.type == "Wife"} do |ps,cp|
      map ps.name <=> cp.name
      map "Wife" >> cp.type
    end
    map p.spouse(ERP::Person) <=> c.partners.find{|cp|cp.type == "Friend"} do |ps,cp|
      map ps.name <=> cp.name
      map "Friend" >> cp.type
    end   
    map p.phones(ERP::Phone)[] <=> c.phones[] do |a, b|
      map a.number <=> b.self
    end

    `Hash to field`
    map p.properties[:country] <=> c.country

    `subobject to fields`
    map p.main_phone(ERP::Phone) <=> c.self do |a, b|
      map a.number <=> b.main_phone
      map a.type <=> b.main_phone_type
    end

    #TODO one to many
    #map p.name << [c.first_name, c.surname] do |fname, surname|
    #  fname + " " + surname
    #end
    #map p.name.split >> [c.first_name, c.surname]
    map p.corporation << c.self do |client|
      "#{client.company} #{client.company_suffix}" unless client.company.nil?
    end
    map p.corporation >> c.company do |corpo|
      corpo.split(" ")[0]
    end
    map p.corporation >> c.company_suffix do |corpo|
      corpo.split(" ")[1]
    end
    `constants` 
    map p.type << "NaN"
    map "Last" >> c.order_by
    
    `func` 
    map p.date_updated << func do
      Date.today
    end
    map func >> c.updated do 
      Time.now
    end
  end
  `Example of submaps autodiscovery`
  map :Group, :ClientList do |g,cl|
    map g.main(ERP::Person) <=> cl.leader(CRM::Client)
    map g.list(ERP::Person)[] <=> cl.clients(CRM::Client)[]
  end
end
