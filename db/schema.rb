# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140710132155) do

  create_table "customers", force: true do |t|
    t.string   "name"
    t.string   "phone_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.integer  "customer_id"
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["customer_id"], name: "index_locations_on_customer_id"

  create_table "messages", force: true do |t|
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "customer_id"
  end

  add_index "messages", ["customer_id"], name: "index_messages_on_customer_id"

  create_table "order_items", force: true do |t|
    t.integer  "pizza_id"
    t.string   "size"
    t.integer  "quantity"
    t.float    "price"
    t.integer  "order_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id"
  add_index "order_items", ["pizza_id"], name: "index_order_items_on_pizza_id"

  create_table "orders", force: true do |t|
    t.integer  "customer_id"
    t.integer  "outlet_id"
    t.integer  "location_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id"
  add_index "orders", ["location_id"], name: "index_orders_on_location_id"
  add_index "orders", ["outlet_id"], name: "index_orders_on_outlet_id"

  create_table "outlet_contacts", force: true do |t|
    t.integer  "outlet_id"
    t.string   "phone_number"
    t.integer  "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "outlet_contacts", ["outlet_id"], name: "index_outlet_contacts_on_outlet_id"

  create_table "outlets", force: true do |t|
    t.string   "name"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pizzas", force: true do |t|
    t.string   "name"
    t.float    "medium_price"
    t.float    "small_price"
    t.float    "large_price"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "steps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "order_type"
    t.integer  "customer_id"
  end

  add_index "steps", ["customer_id"], name: "index_steps_on_customer_id"

  create_table "surburbs", force: true do |t|
    t.string   "name"
    t.integer  "outlet_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "surburbs", ["outlet_id"], name: "index_surburbs_on_outlet_id"

end
