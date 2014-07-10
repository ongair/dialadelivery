# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# os = Outlet.all
# os.each do |o|
# 	o.delete
# end

# os = OutletContact.all
# os.each do |o|
# 	o.delete
# end

Outlet.find_or_create_by_name! name: "Pizza Inn Ngong Road", latitude: -1.299965, longitude: 36.789738
Outlet.find_or_create_by_name! name: "Pizza Inn Junction", latitude: -1.298225, longitude: 36.762011
Outlet.find_or_create_by_name! name: "Pizza Inn-Buruburu", latitude: -1.29515, longitude: 36.876854
Outlet.find_or_create_by_name! name: "Pizza Inn Valley Arcade ", latitude: -1.2907575, longitude: 36.7694968
Outlet.find_or_create_by_name! name: "Pizza Inn-Ridgeways, Kiambu Road", latitude: -1.2309994, longitude: 36.8421063
Outlet.find_or_create_by_name! name: "Pizza Inn-Rongai, Kobil", latitude: -1.396806, longitude: 36.7556045
Outlet.find_or_create_by_name! name: "Pizza Inn, Muindi Mbingu Street", latitude: -1.281395, longitude: 36.818753
Outlet.find_or_create_by_name! name: "Pizza Inn- Moi Avenue", latitude: -1.284574, longitude: 36.824798
Outlet.find_or_create_by_name! name: "Pizza Inn-Waiyaki Way", latitude: -1.260175, longitude: 36.785388
Outlet.find_or_create_by_name! name: "Pizza Inn-Westlands", latitude: -1.263536, longitude: 36.8028348
Outlet.find_or_create_by_name! name: "Pizza Inn-Parklands", latitude: -1.263964, longitude: 36.824224
Outlet.find_or_create_by_name! name: "Pizza Inn-Langata,Road", latitude: -1.3402464, longitude: 36.7489705
Outlet.find_or_create_by_name! name: "Pizza Inn-Lusaka Road", latitude: -1.298974, longitude: 36.837171
Outlet.find_or_create_by_name! name: "Pizza Inn, Embakasi", latitude: -1.3269235, longitude: 36.8938437
Outlet.find_or_create_by_name! name: "Pizza Inn-Greenspan", latitude: -1.28865, longitude: 36.900686
Outlet.find_or_create_by_name! name: "Pizza Inn-Thika Road Mall", latitude: -1.220012, longitude: 36.889139
Outlet.find_or_create_by_name! name: "Pizza Inn-Kitengela", latitude: -1.476905, longitude: 36.958589
Outlet.find_or_create_by_name! name: "Pizza Inn-City Mall, Nyali Road", latitude: -4.019644, longitude: 39.720836
Outlet.find_or_create_by_name! name: "Pizza Inn Likoni", latitude: -4.091367, longitude: 39.649263

outlet1 = Outlet.all[0].id
outlet2 = Outlet.all[1].id

Surburb.find_or_create_by_name_and_outlet_id! :outlet_id=>outlet1, :name=>"Ihub"
Surburb.find_or_create_by_name_and_outlet_id! :outlet_id=>outlet2, :name=>"Jamuhuri"



OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet1, phone_number: "254722946639"
#OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet1, phone_number: "254712345635"

OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: outlet2, phone_number: "254722784921"
