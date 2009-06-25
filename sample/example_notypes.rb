# Example of map for given object domains CRM and ERP
require 'mappum'


Mappum.catalogue_add "NOTYPE-CRM-ERP" do

  map :person, :client do |p, c|

    #simple mapping
    map p.title <=> c.title
    
    #map with simple function call
    map p.person_id << c.id.downcase
    map p.person_id.upcase >> c.id

    #dictionary use
    map p.sex <=> c.sex_id, :dict => {"F" => "1", "M" => "2"}

    #submaps
    map p.address <=> c.address do |a, b|
      map a.street <=> b.street
      #etc.
    end
    
    #xml attributes
    map p.xmlattr_id <=>  c.xmlattr_ident
    
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

    map p.phones[] <=> c.phones[] do |a, b|
      map a.number <=> b.self
    end

    #subobject to fields
    map p.main_phone <=> c.self do |a, b|
      map a.number <=> b.main_phone
      map a.type <=> b.main_phone_type
    end

    #TODO one to many
    #map p.name << [c.first_name, c.surname] do |fname, surname|
    #  fname + " " + surname
    #end
    #map p.name.split >> [c.first_name, c.surname]

  end
end