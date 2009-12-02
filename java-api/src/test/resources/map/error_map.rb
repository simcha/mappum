# Example of map for given object domains CRM and ERP
require 'mappum'
require 'java'
import 'iv.Client'
import 'iv.Person'
require 'date'

Mappum.catalogue_add "Error" do

  map Person,Client do |p, c|
    #submaps
    map p.address(Person::Address) <=> c.address(Client::Address) do |a, b|
      map a.wrong <=> b.name
    end
      
  end
end
