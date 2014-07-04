# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

outlets = Outlet.all
outlets.each do |o|
	o.delete
end

outletscontacts = OutletContact.all
outletscontacts.each do |o|
	o.delete
end


# Outlet.create! name: "Pizza Inn Ngong Road", latitude: -1.299965, longitude: 36.789738
# Outlet.create! name: "Pizza Inn Junction", latitude: -1.298225, longitude: 36.762011

# OutletContact.create! outlet_id: 1, phone_number: "254722946639", priority: 1
# OutletContact.create! outlet_id: 1, phone_number: "254712345635", priority: 2

# OutletContact.create! outlet_id: 2, phone_number: "2540203861961", priority: 1
# OutletContact.create! outlet_id: 2, phone_number: "254722784921", priority: 2