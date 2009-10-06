require 'date'
require 'time'

Mappum.catalogue_add "MAPPUM_AUTOCONV" do
  map Date, String do |a,b|
    map a.self << b.self do |b1|
      Date.parse(b1)
    end

    map a.self >> b.self do |a1|
      a1.to_s
    end
  end
  map Time, String do |a,b|
    map a.self << b.self do |b1|
      Time.parse(b1)
    end

    map a.self >> b.self do |a1|
      a1.rfc2822
    end
  end
  map Fixnum, String do |a,b|
    map a.self << b.self do |b1|
      b1.to_i
    end

    map a.self >> b.self do |a1|
      a1.to_s
    end
  end
  map Float, String do |a,b|
    map a.self << b.self do |b1|
      b1.to_f
    end

    map a.self >> b.self do |a1|
      a1.to_s
    end
  end


end
