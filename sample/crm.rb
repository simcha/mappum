module CRM
  class Client
    attr_accessor :title, :key,  :key2, :first_name, :surname, :address, 
      :sex_id, :phones, :emails
  end
  class Address
    attr_accessor :street
  end
end
