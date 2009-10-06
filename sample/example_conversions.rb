require 'date'

Mappum.catalogue_add do

  map :typed,:stringed do |t,s|
     map t.date(Date) <=> s.date(String)
     map t.time(Time) <=> s.time(String)
     map t.fixnum(Fixnum) <=> s.fixnum(String)
     map t.float(Float) <=> s.float(String)
  end
end
