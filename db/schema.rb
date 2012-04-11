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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120411035230) do

  create_table "equipment", :force => true do |t|
    t.integer  "laboratory_id"
    t.string   "name"
    t.text     "description"
    t.decimal  "hourly_rate",   :precision => 6, :scale => 2
    t.string   "status",                                      :default => "1"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
  end

  add_index "equipment", ["laboratory_id"], :name => "index_equipment_on_laboratory_id"

  create_table "laboratories", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "laboratories", ["user_id"], :name => "index_laboratories_on_user_id"

  create_table "laboratory_members", :force => true do |t|
    t.integer  "laboratory_id"
    t.integer  "user_id"
    t.string   "status",        :default => "1"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "laboratory_members", ["laboratory_id"], :name => "index_laboratory_members_on_laboratory_id"
  add_index "laboratory_members", ["user_id"], :name => "index_laboratory_members_on_user_id"

  create_table "laboratory_requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "request_number",  :limit => 20
    t.integer  "consecutive"
    t.integer  "laboratory_id"
    t.integer  "request_type_id"
    t.string   "request_link"
    t.text     "description"
    t.integer  "responsible"
    t.integer  "status",                        :default => 1
    t.datetime "request_date"
    t.datetime "end_date"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "laboratory_requests", ["laboratory_id"], :name => "index_laboratory_requests_on_laboratory_id"
  add_index "laboratory_requests", ["request_type_id"], :name => "index_laboratory_requests_on_request_type_id"
  add_index "laboratory_requests", ["responsible"], :name => "index_laboratory_requests_on_responsible"
  add_index "laboratory_requests", ["user_id"], :name => "index_laboratory_requests_on_user_id"

  create_table "laboratory_services", :force => true do |t|
    t.integer  "laboratory_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "laboratory_services", ["laboratory_id"], :name => "index_laboratory_services_on_laboratory_id"

  create_table "materials", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "unit_id"
    t.decimal  "unit_price",  :precision => 6, :scale => 2
    t.string   "status",                                    :default => "1"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
  end

  create_table "requested_service_equipments", :force => true do |t|
    t.integer  "requested_service_id"
    t.integer  "equipment_id"
    t.decimal  "hours",                :precision => 4, :scale => 2
    t.decimal  "hourly_rate",          :precision => 6, :scale => 2
    t.text     "details"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "requested_service_equipments", ["equipment_id"], :name => "index_requested_service_equipments_on_equipment_id"
  add_index "requested_service_equipments", ["requested_service_id"], :name => "index_requested_service_equipments_on_requested_service_id"

  create_table "requested_service_materials", :force => true do |t|
    t.integer  "requested_service_id"
    t.integer  "material_id"
    t.decimal  "quantity",             :precision => 10, :scale => 10
    t.decimal  "unit_price",           :precision => 6,  :scale => 2
    t.text     "details"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "requested_service_materials", ["material_id"], :name => "index_requested_service_materials_on_material_id"
  add_index "requested_service_materials", ["requested_service_id"], :name => "index_requested_service_materials_on_requested_service_id"

  create_table "requested_service_technicians", :force => true do |t|
    t.integer  "requested_service_id"
    t.integer  "user_id"
    t.decimal  "hours",                :precision => 4, :scale => 2
    t.decimal  "hourly_wage",          :precision => 6, :scale => 2
    t.text     "details"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "requested_service_technicians", ["requested_service_id"], :name => "index_requested_service_technicians_on_requested_service_id"
  add_index "requested_service_technicians", ["user_id"], :name => "index_requested_service_technicians_on_user_id"

  create_table "requested_services", :force => true do |t|
    t.integer  "laboratory_service_id"
    t.integer  "sample_id"
    t.text     "details"
    t.string   "status",                :default => "1"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "requested_services", ["laboratory_service_id"], :name => "index_requested_services_on_laboratory_service_id"
  add_index "requested_services", ["sample_id"], :name => "index_requested_services_on_sample_id"

  create_table "samples", :force => true do |t|
    t.integer  "laboratory_request_id"
    t.string   "identification"
    t.text     "description"
    t.string   "status",                :default => "1"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "samples", ["laboratory_request_id"], :name => "index_samples_on_laboratory_request_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "access",     :default => "1"
    t.string   "status",     :default => "1"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

end
