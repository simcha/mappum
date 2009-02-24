# Example of map for given object domains CRM and ERP
require 'mappum'
require 'sample/erp'
require 'sample/crm'

Mappum.catalogue_add "CRM-ERP" do

  #TODO fix to ERP::Person <=> CRM::Client

  map [ERP::Person, CRM::Client] do |p, c|

    #simple mapping
    map p.title <=> c.title

    #map with simple function call
    map p.person_id << c.key.downcase 
    map p.person_id.upcase >> c.key

    #dictionary use
    map p.sex <=> c.sex_id, :dict => {"F" => "1", "M" => "2"}

    #submaps
    map p.address(ERP::Address) <=> c.address(CRM::Address) do |a, b|
      map a.street <=> b.street
      #etc.
    end

    #compicated finc call
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
    #field to array and array to field
    map p.email1 <=> c.emails[0]
    map p.email2 <=> c.emails[1]
    map p.email3 <=> c.emails[2]

    map p.phones(ERP::Phone)[] <=> c.phones[] do |a, b|
      map a.number <=> b
    end

    #TODO one to many
    #map p.name << [c.first_name, c.surname] do |fname, surname|
    #  fname + " " + surname
    #end
    #map p.name.split >> [c.first_name, c.surname]

  end
end