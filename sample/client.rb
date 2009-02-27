require 'xsd/qname'

# {}client
#   title - SOAP::SOAPString
#   id - SOAP::SOAPString
#   first_name - SOAP::SOAPString
#   surname - SOAP::SOAPString
#   sex_id - SOAP::SOAPString
#   phones - SOAP::SOAPString
#   emails - SOAP::SOAPString
#   main_phone - SOAP::SOAPString
#   main_phone_type - SOAP::SOAPString
#   address - Client::Address
class Client

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
  attr_accessor :id
  attr_accessor :first_name
  attr_accessor :surname
  attr_accessor :sex_id
  attr_accessor :phones
  attr_accessor :emails
  attr_accessor :main_phone
  attr_accessor :main_phone_type
  attr_accessor :address

  def initialize(title = nil, id = nil, first_name = nil, surname = nil, sex_id = nil, phones = [], emails = [], main_phone = [], main_phone_type = [], address = nil)
    @title = title
    @id = id
    @first_name = first_name
    @surname = surname
    @sex_id = sex_id
    @phones = phones
    @emails = emails
    @main_phone = main_phone
    @main_phone_type = main_phone_type
    @address = address
  end
end
