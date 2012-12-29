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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121228235136) do

  create_table "activity_logs", :force => true do |t|
    t.integer  "user_id"
    t.integer  "service_request_id"
    t.integer  "sample_id"
    t.integer  "requested_service_id"
    t.string   "message_type"
    t.integer  "requested_service_status"
    t.text     "message"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "activity_logs", ["requested_service_id"], :name => "index_activity_logs_on_requested_service_id"
  add_index "activity_logs", ["sample_id"], :name => "index_activity_logs_on_sample_id"
  add_index "activity_logs", ["service_request_id"], :name => "index_activity_logs_on_service_request_id"
  add_index "activity_logs", ["user_id"], :name => "index_activity_logs_on_user_id"

  create_table "business_units", :force => true do |t|
    t.string   "prefix",     :limit => 5
    t.string   "name"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "client_contacts", :force => true do |t|
    t.integer  "client_id"
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.integer  "status",     :default => 1
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "client_contacts", ["client_id"], :name => "index_client_contacts_on_client_id"

  create_table "client_types", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "status",      :default => 1
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "clients", :force => true do |t|
    t.string   "name"
    t.integer  "client_type_id"
    t.string   "rfc"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.integer  "state_id"
    t.integer  "country_id"
    t.string   "phone"
    t.string   "fax"
    t.string   "email"
    t.integer  "status",         :default => 1
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "clients", ["client_type_id"], :name => "index_clients_on_client_type_id"
  add_index "clients", ["country_id"], :name => "index_clients_on_country_id"
  add_index "clients", ["state_id"], :name => "index_clients_on_state_id"

  create_table "countries", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "external_requests", :force => true do |t|
    t.integer  "service_request_id"
    t.date     "request_date"
    t.string   "service_number"
    t.boolean  "is_acredited"
    t.text     "client_agreements"
    t.text     "notes"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "client_id"
    t.integer  "client_contact_id"
  end

  add_index "external_requests", ["client_contact_id"], :name => "index_external_requests_on_client_contact_id"
  add_index "external_requests", ["client_id"], :name => "index_external_requests_on_client_id"

  create_table "laboratories", :force => true do |t|
    t.string   "name"
    t.string   "prefix",           :limit => 5
    t.text     "description"
    t.integer  "business_unit_id"
    t.integer  "user_id"
    t.integer  "status",                        :default => 1
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "laboratories", ["user_id"], :name => "index_laboratories_on_user_id"

  create_table "laboratory_members", :force => true do |t|
    t.integer  "laboratory_id"
    t.integer  "user_id"
    t.string   "status",        :default => "1"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "access",        :default => "1"
  end

  add_index "laboratory_members", ["laboratory_id"], :name => "index_laboratory_members_on_laboratory_id"
  add_index "laboratory_members", ["user_id"], :name => "index_laboratory_members_on_user_id"

  create_table "laboratory_services", :force => true do |t|
    t.integer  "laboratory_id"
    t.integer  "service_type_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "laboratory_services", ["laboratory_id"], :name => "index_laboratory_services_on_laboratory_id"
  add_index "laboratory_services", ["service_type_id"], :name => "index_laboratory_services_on_service_type_id"

  create_table "materials", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "unit_id"
    t.decimal  "unit_price",  :precision => 6, :scale => 2
    t.string   "status",                                    :default => "1"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
  end

  create_table "request_types", :force => true do |t|
    t.string   "short_name", :limit => 20
    t.string   "name"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
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

  create_table "requested_service_others", :force => true do |t|
    t.integer  "requested_service_id"
    t.integer  "other_type"
    t.string   "concept"
    t.text     "details"
    t.decimal  "price",                :precision => 6, :scale => 2
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
  end

  add_index "requested_service_others", ["requested_service_id"], :name => "index_requested_service_others_on_requested_service_id"

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
    t.integer  "consecutive"
    t.string   "number",                :limit => 20
    t.text     "details"
    t.integer  "user_id"
    t.integer  "suggested_user_id"
    t.string   "status",                              :default => "1"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  add_index "requested_services", ["laboratory_service_id"], :name => "index_requested_services_on_laboratory_service_id"
  add_index "requested_services", ["sample_id"], :name => "index_requested_services_on_sample_id"
  add_index "requested_services", ["suggested_user_id"], :name => "index_requested_services_on_suggested_user_id"
  add_index "requested_services", ["user_id"], :name => "index_requested_services_on_user_id"

  create_table "samples", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "consecutive"
    t.string   "number",             :limit => 20
    t.string   "identification"
    t.text     "description"
    t.string   "status",                           :default => "1"
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.integer  "quantity"
  end

  add_index "samples", ["service_request_id"], :name => "index_samples_on_service_request_id"

  create_table "service_files", :force => true do |t|
    t.integer  "user_id"
    t.integer  "service_request_id"
    t.integer  "sample_id"
    t.integer  "requested_service_id"
    t.integer  "file_type"
    t.string   "description"
    t.string   "file"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "service_files", ["requested_service_id"], :name => "index_service_files_on_requested_service_id"
  add_index "service_files", ["sample_id"], :name => "index_service_files_on_sample_id"
  add_index "service_files", ["service_request_id"], :name => "index_service_files_on_service_request_id"
  add_index "service_files", ["user_id"], :name => "index_service_files_on_user_id"

  create_table "service_requests", :force => true do |t|
    t.integer  "user_id"
    t.string   "number",          :limit => 20
    t.integer  "request_type_id"
    t.string   "request_link"
    t.text     "description"
    t.integer  "status",                        :default => 1
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.integer  "supervisor_id"
  end

  add_index "service_requests", ["request_type_id"], :name => "index_service_requests_on_request_type_id"
  add_index "service_requests", ["supervisor_id"], :name => "index_service_requests_on_supervisor_id"
  add_index "service_requests", ["user_id"], :name => "index_service_requests_on_user_id"

  create_table "service_types", :force => true do |t|
    t.string   "short_name", :limit => 20
    t.string   "name"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "states", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "units", :force => true do |t|
    t.string   "short_name", :limit => 10
    t.string   "name"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "employee_number"
    t.string   "first_name"
    t.string   "last_name"
    t.decimal  "hourly_wage",     :precision => 6, :scale => 2
    t.string   "access",                                        :default => "1"
    t.string   "status",                                        :default => "1"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.integer  "supervisor1_id"
    t.integer  "supervisor2_id"
  end

  add_index "users", ["supervisor1_id"], :name => "index_users_on_supervisor1_id"
  add_index "users", ["supervisor2_id"], :name => "index_users_on_supervisor2_id"

end
