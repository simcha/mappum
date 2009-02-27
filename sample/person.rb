require 'xsd/qname'

# {}phone
#   number - SOAP::SOAPString
#   extension - SOAP::SOAPString
#   type - SOAP::SOAPString
class Phone
  attr_accessor :number
  attr_accessor :extension
  attr_accessor :type

  def initialize(number = nil, extension = nil, type = nil)
    @number = number
    @extension = extension
    @type = type
  end
end

# {}person
#   title - SOAP::SOAPString
#   person_id - SOAP::SOAPString
#   name - SOAP::SOAPString
#   surname - SOAP::SOAPString
#   sex - SOAP::SOAPString
#   email1 - SOAP::SOAPString
#   email2 - SOAP::SOAPString
#   email3 - SOAP::SOAPString
#   main_phone - Phone
#   address - Person::Address
#   phones - Phone
class Person

  # inner class for member: address
  # {}address
  #   street - SOAP::SOAPString
  #   city - SOAP::SOAPString
  class Address
    attr_accessor :street
    attr_accessor :city

    def initialize(street = nil, city = nil)
      @street = street
      @city = city
    end
  end

  attr_accessor :title
  attr_accessor :person_id
  attr_accessor :name
  attr_accessor :surname
  attr_accessor :sex
  attr_accessor :email1
  attr_accessor :email2
  attr_accessor :email3
  attr_accessor :main_phone
  attr_accessor :address
  attr_accessor :phones

  def initialize(title = nil, person_id = nil, name = nil, surname = nil, sex = nil, email1 = nil, email2 = nil, email3 = nil, main_phone = nil, address = nil, phones = [])
    @title = title
    @person_id = person_id
    @name = name
    @surname = surname
    @sex = sex
    @email1 = email1
    @email2 = email2
    @email3 = email3
    @main_phone = main_phone
    @address = address
    @phones = phones
  end
end
