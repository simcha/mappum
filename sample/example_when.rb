Mappum.catalogue_add do
  map :foo, :bar do |f, b|
    map_when(:>){|foo| foo.age < 10}

    #map f.mem <=> b.tem, :when_l2r => lambda {|mem| mem > 10}
    #or the same
    map f.mem <=> b.tem do 
       map_when(:>) {|mem| mem > 10}
    end
    map f.mem <=> b.gem, :when_l2r => lambda {|mem| mem <= 10}
    map f.pol >> b.gol, :when => lambda {|pol| pol != 0}
  end
end
