# Example of map for any type

Mappum.catalogue_add do

  map :address, :adresse do |e, f|

    #simple mapping
    map e.city <=> f.ville
    map e.street <=> f.rue
    map e.zip_code <=> f.code_postale

    #map with simple function call
    map e.country << f.pays.downcase
    map e.country.upcase >> f.pays

    #submaps
    map e.house <=> f.maison do |h, m|
      map h.number <=> m.numero
      map h.flat <=> m.appartement 
    end
  
  end

end
