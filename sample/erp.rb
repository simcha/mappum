module ERP
  Person = Struct.new(:title, :type,:date_updated, :person_id,  :id2, :name, :address, :sex,
      :phones, :email1, :email2, :email3, :main_phone, :corporation, :spouse, :properties)
  Address = Struct.new(:street)
  Phone = Struct.new(:number, :extension, :type)

end
