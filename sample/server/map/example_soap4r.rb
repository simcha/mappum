# Example of map for given object domains CRM and ERP

Mappum.catalogue_add do
  `
  Mapping Erp system Person to Crm Client
  `
  map Erp::Person, Client do |p, c|

    #simple mapping
    map p.title <=> c.title

    #map with simple function call
    map p.person_id << c.id.downcase
    map p.person_id.upcase >> c.id

    `Map F to 1 and M to 2`
    map p.sex <=> c.sex_id, :dict => {"F" => "1", "M" => "2"}

    #submaps
    map p.address(Erp::Person::Address) <=> c.address(Client::Address) do |a, b|
      map a.street <=> b.street
      #etc.
    end

    `Add 'ski' to name`
    map p.name >> c.surname do |name|
      name + "ski"
    end
    `Remove "ski" from surname`
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

    map p.phones(Erp::Phone)[] <=> c.phones[] do |a, b|
      map a.number <=> b.self
    end

    #subobject to fields
    map p.main_phone(Erp::Phone) <=> c.self do |a, b|
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