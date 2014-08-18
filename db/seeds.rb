# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ngongroad = Outlet.find_or_create_by_name! name: "Pizza Inn, Ngong Road", latitude: -1.299965, longitude: 36.789738
buruburu = Outlet.find_or_create_by_name! name: "Pizza Inn-Buruburu", latitude: -1.29515, longitude: 36.876854
valleyarcade = Outlet.find_or_create_by_name! name: "Pizza Inn Valley Arcade ", latitude: -1.2907575, longitude: 36.7694968
ridgeways = Outlet.find_or_create_by_name! name: "Pizza Inn-Ridgeways, Kiambu Road", latitude: -1.2309994, longitude: 36.8421063
rongai = Outlet.find_or_create_by_name! name: "Pizza Inn-Rongai, Kobil", latitude: -1.396806, longitude: 36.7556045
muindimbingu = Outlet.find_or_create_by_name! name: "Pizza Inn, Muindi Mbingu Street", latitude: -1.281395, longitude: 36.818753
moiavenue = Outlet.find_or_create_by_name! name: "Pizza Inn- Moi Avenue", latitude: -1.284574, longitude: 36.824798
waiyaki = Outlet.find_or_create_by_name! name: "Pizza Inn-Waiyaki Way", latitude: -1.260175, longitude: 36.785388
westlands = Outlet.find_or_create_by_name! name: "Pizza Inn-Westlands", latitude: -1.263536, longitude: 36.8028348
parklands = Outlet.find_or_create_by_name! name: "Pizza Inn-Parklands", latitude: -1.263964, longitude: 36.824224
langata = Outlet.find_or_create_by_name! name: "Pizza Inn-Langata,Road", latitude: -1.3402464, longitude: 36.7489705
lusaka = Outlet.find_or_create_by_name! name: "Pizza Inn-Lusaka Road", latitude: -1.298974, longitude: 36.837171
embakasi = Outlet.find_or_create_by_name! name: "Pizza Inn, Embakasi", latitude: -1.3269235, longitude: 36.8938437
greenspan = Outlet.find_or_create_by_name! name: "Pizza Inn-Greenspan", latitude: -1.28865, longitude: 36.900686
thikaroadmall = Outlet.find_or_create_by_name! name: "Pizza Inn-Thika Road Mall", latitude: -1.220012, longitude: 36.889139
kitengela = Outlet.find_or_create_by_name! name: "Pizza Inn-Kitengela", latitude: -1.476905, longitude: 36.958589
nyali = Outlet.find_or_create_by_name! name: "Pizza Inn-City Mall, Nyali Road", latitude: -4.019644, longitude: 39.720836
likoni = Outlet.find_or_create_by_name! name: "Pizza Inn Likoni", latitude: -4.091367, longitude: 39.649263
bellevue = Outlet.find_or_create_by_name! name: "Pizza Inn-Bellevue, Nairobi, Kenya", latitude: -1.319342, longitude: 36.836865


OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: buruburu.id, phone_number: "0738001381"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: buruburu.id, phone_number: "0727546893"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: likoni.id, phone_number: "0729333441"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: likoni.id, phone_number: "0738001427"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: nyali.id, phone_number: "0722903927"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: nyali.id, phone_number: "0736095740"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: kitengela.id, phone_number: "0704867246"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: kitengela.id, phone_number: "0737991099"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: kitengela.id, phone_number: "0770614657"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: thikaroadmall.id, phone_number: "0700416858"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: thikaroadmall.id, phone_number: "0733414029"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: thikaroadmall.id, phone_number: "0771868743"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: greenspan.id, phone_number: "0708339515"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: greenspan.id, phone_number: "0774309808"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: greenspan.id, phone_number: "0786464567"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: embakasi.id, phone_number: "0702111653"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: embakasi.id, phone_number: "0738012130"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ngongroad.id, phone_number: "0734529478"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ngongroad.id, phone_number: "0720294568"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ngongroad.id, phone_number: "0722457522"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ngongroad.id, phone_number: "0733572304"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ngongroad.id, phone_number: "0202609377"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: bellevue.id, phone_number: "0722457520"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: bellevue.id, phone_number: "0735014042"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: lusaka.id, phone_number: "0723278916"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: lusaka.id, phone_number: "0735643714"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: langata.id, phone_number: "0708276296"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: langata.id, phone_number: "0731850290"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: langata.id, phone_number: "0774309810"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: parklands.id, phone_number: "0733485855"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: parklands.id, phone_number: "0721296268"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: westlands.id, phone_number: "0734265718"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: westlands.id, phone_number: "0723390317"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: westlands.id, phone_number: "0738227207"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: westlands.id, phone_number: "0712681749"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: waiyaki.id, phone_number: "0723971417"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: waiyaki.id, phone_number: "0735643717"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: moiavenue.id, phone_number: "0722945639"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: moiavenue.id, phone_number: "0733120655"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: moiavenue.id, phone_number: "0773832997"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: muindimbingu.id, phone_number: "0727448804"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: muindimbingu.id, phone_number: "0736100281"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: muindimbingu.id, phone_number: "0722475672"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ridgeways.id, phone_number: "0710638439"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ridgeways.id, phone_number: "0731830805"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: ridgeways.id, phone_number: "0775174872"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: valleyarcade.id, phone_number: "0723235740"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: valleyarcade.id, phone_number: "0738235740"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: rongai.id, phone_number: "0729867378"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: rongai.id, phone_number: "0733396973"
OutletContact.find_or_create_by_phone_number_and_outlet_id! outlet_id: rongai.id, phone_number: "0775555091"