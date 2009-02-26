module CRM
  class Client
    attr_accessor :title, :id,  :key, :first_name, :surname, :address,
      :sex_id, :phones, :emails, :main_phone, :main_phone_type
  end
  class Address
    attr_accessor :street
  end
end