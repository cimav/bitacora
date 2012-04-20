# Business Units
puts "Populating Business Units..."
BusinessUnit.delete_all
open("db/seeds/business_units.txt") do |bu|
    bu.read.each_line do |b|
        prefix, name = b.chomp.split("|")
        BusinessUnit.create!(:prefix => prefix, :name => name)
    end
end


# Laboratories
puts "Populating Laboratories"
Laboratory.delete_all
open("db/seeds/laboratories.txt") do |labs|
    labs.read.each_line do |l|
        name, bu = l.chomp.split("|")
        Laboratory.create!(:name => name, :business_unit_id => bu)
    end
end

# Request Types
puts "Populating Request types"
RequestType.delete_all
open("db/seeds/request_types.txt") do |req|
    req.read.each_line do |r|
        short_name, name = r.chomp.split("|")
        RequestType.create!(:name => name, :short_name => short_name)
    end
end

