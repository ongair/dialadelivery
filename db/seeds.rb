# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

os = Outlet.all
os.each do |o|
	o.delete
end

os = OutletContact.all
os.each do |o|
	o.delete
end

# Outlet.find_or_create_by_name! name: "Pizza Inn Ngong Road", latitude: -1.299965, longitude: 36.789738
# Outlet.find_or_create_by_name! name: "Pizza Inn Junction", latitude: -1.298225, longitude: 36.762011

# outlet1 = Outlet.all[0].id
# outlet2 = Outlet.all[1].id


# OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet1, phone_number: "254722946639"
# OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet1, phone_number: "254712345635"

# OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet2, phone_number: "2540203861961"
# OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet2, phone_number: "254722784921"