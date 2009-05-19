module ERP
  Person = Struct.new(:title, :person_id,  :id2, :name, :address, :sex,
      :phones, :email1, :email2, :email3, :main_phone, :corporation)
  Address = Struct.new(:street)
  Phone = Struct.new(:number, :extension, :type)

end
