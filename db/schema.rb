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

ActiveRecord::Schema.define(version: 20180427183931) do

  create_table "P170080", id: false, force: :cascade do |t|
    t.integer  "id",                 limit: 4,        default: 0,   null: false
    t.integer  "service_request_id", limit: 4
    t.integer  "consecutive",        limit: 4
    t.string   "number",             limit: 20
    t.string   "identification",     limit: 255
    t.text     "description",        limit: 16777215
    t.string   "status",             limit: 255,      default: "1"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "quantity",           limit: 4
    t.string   "code",               limit: 255
    t.integer  "system_id",          limit: 4
  end

  create_table "activity_logs", force: :cascade do |t|
    t.integer  "user_id",                  limit: 4
    t.integer  "service_request_id",       limit: 4
    t.integer  "sample_id",                limit: 4
    t.integer  "requested_service_id",     limit: 4
    t.string   "message_type",             limit: 255
    t.integer  "requested_service_status", limit: 4
    t.text     "message",                  limit: 16777215
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "activity_logs", ["requested_service_id"], name: "index_activity_logs_on_requested_service_id", using: :btree
  add_index "activity_logs", ["sample_id"], name: "index_activity_logs_on_sample_id", using: :btree
  add_index "activity_logs", ["service_request_id"], name: "index_activity_logs_on_service_request_id", using: :btree
  add_index "activity_logs", ["user_id"], name: "index_activity_logs_on_user_id", using: :btree

  create_table "adan", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "alerts", force: :cascade do |t|
    t.integer  "user_id",               limit: 4
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "technician",            limit: 4
    t.integer  "equipment_id",          limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "message_type",          limit: 255
    t.text     "message",               limit: 65535
    t.integer  "status",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "alerts", ["equipment_id"], name: "index_alerts_on_equipment_id", using: :btree
  add_index "alerts", ["laboratory_service_id"], name: "index_alerts_on_laboratory_service_id", using: :btree
  add_index "alerts", ["technician"], name: "index_alerts_on_technician", using: :btree
  add_index "alerts", ["user_id"], name: "index_alerts_on_user_id", using: :btree

  create_table "aleyda", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "ariz", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "arturo", id: false, force: :cascade do |t|
    t.string  "number",        limit: 20
    t.integer "supervisor_id", limit: 4
  end

  create_table "asignacionusuario", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4
    t.integer "reguser",              limit: 4
    t.decimal "regh",                           precision: 6, scale: 2
    t.integer "assuser",              limit: 4
    t.decimal "assh",                           precision: 6, scale: 2
    t.integer "user_id",              limit: 4
  end

  create_table "asignacionusuario100", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4
    t.integer "reguser",              limit: 4
    t.integer "assuser",              limit: 4
    t.integer "user_id",              limit: 4
  end

  create_table "aux_reporte_finalizados", id: false, force: :cascade do |t|
    t.integer  "sigre_id",               limit: 4
    t.string   "codigo",                 limit: 20
    t.string   "tipo",                   limit: 255
    t.string   "cliente",                limit: 255
    t.text     "descripcion",            limit: 65535
    t.integer  "laboratorio_id",         limit: 4,                                  default: 0
    t.string   "laboratorio",            limit: 255
    t.string   "clasificador",           limit: 255
    t.text     "servicio_laboratorio",   limit: 16777215
    t.date     "fecha_inicio"
    t.date     "fecha_fin"
    t.datetime "fecha_finalizado_real"
    t.string   "cotizacion_consecutivo", limit: 255
    t.decimal  "precio_venta",                            precision: 10, scale: 2,  default: 0.0, null: false
    t.decimal  "costo_interno",                           precision: 42, scale: 4,  default: 0.0, null: false
    t.decimal  "total",                                   precision: 42, scale: 4,  default: 0.0, null: false
    t.decimal  "porcentaje",                              precision: 53, scale: 8,  default: 0.0, null: false
    t.decimal  "corresponde",                             precision: 65, scale: 14, default: 0.0, null: false
  end

  create_table "bak_laboratory_services", id: false, force: :cascade do |t|
    t.integer  "id",                                   limit: 4,                                 default: 0,     null: false
    t.integer  "laboratory_id",                        limit: 4
    t.integer  "service_type_id",                      limit: 4
    t.text     "name",                                 limit: 16777215
    t.text     "description",                          limit: 16777215
    t.datetime "created_at",                                                                                     null: false
    t.datetime "updated_at",                                                                                     null: false
    t.decimal  "internal_cost",                                         precision: 10, scale: 2
    t.integer  "is_catalog",                           limit: 4,                                 default: 0
    t.decimal  "sale_price",                                            precision: 10, scale: 2
    t.integer  "is_exclusive_vinculacion",             limit: 4,                                 default: 0
    t.decimal  "evaluation_cost",                                       precision: 10, scale: 2
    t.integer  "status",                               limit: 4,                                 default: 0
    t.integer  "laboratory_service_classification_id", limit: 4,                                 default: 0
    t.boolean  "show_web",                             limit: 1,                                 default: false
  end

  create_table "bak_users", id: false, force: :cascade do |t|
    t.integer  "id",               limit: 4,                           default: 0,     null: false
    t.string   "email",            limit: 255
    t.string   "employee_number",  limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.decimal  "hourly_wage",                  precision: 6, scale: 2
    t.string   "access",           limit: 255,                         default: "1"
    t.string   "status",           limit: 255,                         default: "1"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "supervisor1_id",   limit: 4
    t.integer  "supervisor2_id",   limit: 4
    t.boolean  "require_auth",     limit: 1,                           default: false
    t.integer  "business_unit_id", limit: 4,                           default: 1
  end

  create_table "borra", id: false, force: :cascade do |t|
    t.integer "id",              limit: 4,  default: 0, null: false
    t.string  "number",          limit: 20
    t.integer "request_type_id", limit: 4
  end

  create_table "business_units", force: :cascade do |t|
    t.string   "prefix",     limit: 5
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "client_contacts", force: :cascade do |t|
    t.integer  "client_id",  limit: 4
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.string   "email",      limit: 255
    t.integer  "status",     limit: 4,   default: 1
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "client_contacts", ["client_id"], name: "index_client_contacts_on_client_id", using: :btree

  create_table "client_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.integer  "status",      limit: 4,        default: 1
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "client_type_id", limit: 4
    t.string   "rfc",            limit: 255
    t.string   "address1",       limit: 255
    t.string   "address2",       limit: 255
    t.string   "city",           limit: 255
    t.integer  "state_id",       limit: 4
    t.integer  "country_id",     limit: 4
    t.string   "phone",          limit: 255
    t.string   "fax",            limit: 255
    t.string   "email",          limit: 255
    t.integer  "status",         limit: 4,   default: 1
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "clients", ["client_type_id"], name: "index_clients_on_client_type_id", using: :btree
  add_index "clients", ["country_id"], name: "index_clients_on_country_id", using: :btree
  add_index "clients", ["state_id"], name: "index_clients_on_state_id", using: :btree

  create_table "collaborators", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "user_id",            limit: 4
    t.integer  "collaboration_type", limit: 4
    t.integer  "status",             limit: 4, default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collaborators", ["service_request_id"], name: "index_collaborators_on_service_request_id", using: :btree
  add_index "collaborators", ["user_id"], name: "index_collaborators_on_user_id", using: :btree

  create_table "correccion", id: false, force: :cascade do |t|
    t.integer "id",        limit: 4,  default: 0, null: false
    t.integer "rit",       limit: 4,  default: 0, null: false
    t.string  "number",    limit: 20
    t.integer "asignado",  limit: 4
    t.integer "plantilla", limit: 4
  end

  create_table "costo_interno_porcentaje", id: false, force: :cascade do |t|
    t.integer "system_request_id",    limit: 4
    t.integer "requested_service_id", limit: 4
    t.decimal "monto",                          precision: 56, scale: 4
    t.decimal "total",                          precision: 65, scale: 4
    t.decimal "porcentaje",                     precision: 65, scale: 8
  end

  create_table "costo_interno_x_servicio", id: false, force: :cascade do |t|
    t.integer "system_request_id",    limit: 4
    t.integer "service_request_id",   limit: 4
    t.integer "requested_service_id", limit: 4
    t.decimal "monto",                          precision: 56, scale: 4
  end

  create_table "costo_interno_x_solicitud", id: false, force: :cascade do |t|
    t.integer "system_request_id", limit: 4
    t.decimal "total",                       precision: 65, scale: 4
  end

  create_table "countries", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "departments", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "prefix",           limit: 5
    t.text     "description",      limit: 65535
    t.integer  "business_unit_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.integer  "status",           limit: 4,     default: 1
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "eq2", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                 default: 0,   null: false
    t.integer  "laboratory_id",        limit: 4
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 16777215
    t.decimal  "hourly_rate",                           precision: 6,  scale: 2
    t.string   "status",               limit: 255,                               default: "1"
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.string   "item_number",          limit: 255
    t.string   "budget_item",          limit: 255
    t.date     "purchase_date"
    t.decimal  "purchase_price",                        precision: 10, scale: 2
    t.decimal  "internal_hourly_rate",                  precision: 10, scale: 2
    t.decimal  "suggested_price",                       precision: 10, scale: 2
  end

  create_table "eq_bak", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                 default: 0,   null: false
    t.integer  "laboratory_id",        limit: 4
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 16777215
    t.decimal  "hourly_rate",                           precision: 6,  scale: 2
    t.string   "status",               limit: 255,                               default: "1"
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.string   "item_number",          limit: 255
    t.string   "budget_item",          limit: 255
    t.date     "purchase_date"
    t.decimal  "purchase_price",                        precision: 10, scale: 2
    t.decimal  "internal_hourly_rate",                  precision: 10, scale: 2
    t.decimal  "suggested_price",                       precision: 10, scale: 2
  end

  create_table "eq_bak2", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                 default: 0,   null: false
    t.integer  "laboratory_id",        limit: 4
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 16777215
    t.decimal  "hourly_rate",                           precision: 6,  scale: 2
    t.string   "status",               limit: 255,                               default: "1"
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.string   "item_number",          limit: 255
    t.string   "budget_item",          limit: 255
    t.date     "purchase_date"
    t.decimal  "purchase_price",                        precision: 10, scale: 2
    t.decimal  "internal_hourly_rate",                  precision: 10, scale: 2
    t.decimal  "suggested_price",                       precision: 10, scale: 2
  end

  create_table "equipment", force: :cascade do |t|
    t.integer  "laboratory_id",        limit: 4
    t.string   "name",                 limit: 255
    t.text     "description",          limit: 16777215
    t.decimal  "hourly_rate",                           precision: 6,  scale: 2
    t.string   "status",               limit: 255,                               default: "1"
    t.datetime "created_at",                                                                     null: false
    t.datetime "updated_at",                                                                     null: false
    t.string   "item_number",          limit: 255
    t.string   "budget_item",          limit: 255
    t.date     "purchase_date"
    t.decimal  "purchase_price",                        precision: 10, scale: 2
    t.decimal  "internal_hourly_rate",                  precision: 10, scale: 2
    t.decimal  "suggested_price",                       precision: 10, scale: 2
    t.boolean  "show_web",             limit: 1,                                 default: false
  end

  create_table "external_requests", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.date     "request_date"
    t.string   "service_number",     limit: 255
    t.boolean  "is_acredited",       limit: 1
    t.text     "client_agreements",  limit: 16777215
    t.text     "notes",              limit: 16777215
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "client_id",          limit: 4
    t.integer  "client_contact_id",  limit: 4
  end

  add_index "external_requests", ["client_contact_id"], name: "index_external_requests_on_client_contact_id", using: :btree
  add_index "external_requests", ["client_id"], name: "index_external_requests_on_client_id", using: :btree

  create_table "ids_con", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4
  end

  create_table "ids_metro", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "inactive_members", id: false, force: :cascade do |t|
    t.integer  "id",            limit: 4,   default: 0,   null: false
    t.integer  "laboratory_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "status",        limit: 255, default: "1"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "access",        limit: 255, default: "1"
  end

  create_table "lab38", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                default: 0, null: false
    t.integer  "requested_service_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_wage",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "participation",        limit: 4
  end

  create_table "lab41", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                default: 0, null: false
    t.integer  "requested_service_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_wage",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "participation",        limit: 4
  end

  create_table "lab49", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                default: 0, null: false
    t.integer  "requested_service_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_wage",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "participation",        limit: 4
  end

  create_table "laboratories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "prefix",           limit: 255
    t.text     "description",      limit: 16777215
    t.integer  "business_unit_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.integer  "status",           limit: 4,        default: 1
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.boolean  "quote_needs_auth", limit: 1,        default: false
  end

  add_index "laboratories", ["user_id"], name: "index_laboratories_on_user_id", using: :btree

  create_table "laboratory_images", force: :cascade do |t|
    t.integer  "user_id",       limit: 4
    t.integer  "laboratory_id", limit: 4
    t.string   "description",   limit: 255
    t.string   "file",          limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "laboratory_images", ["laboratory_id"], name: "index_laboratory_images_on_laboratory_id", using: :btree

  create_table "laboratory_members", force: :cascade do |t|
    t.integer  "laboratory_id", limit: 4
    t.integer  "user_id",       limit: 4
    t.string   "status",        limit: 255, default: "1"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "access",        limit: 255, default: "1"
  end

  add_index "laboratory_members", ["laboratory_id"], name: "index_laboratory_members_on_laboratory_id", using: :btree
  add_index "laboratory_members", ["user_id"], name: "index_laboratory_members_on_user_id", using: :btree

  create_table "laboratory_service_additionals", force: :cascade do |t|
    t.integer  "laboratory_service_id", limit: 4
    t.string   "name",                  limit: 255
    t.integer  "type",                  limit: 4
    t.text     "value",                 limit: 65535
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "position",              limit: 4,     default: 0
  end

  create_table "laboratory_service_classifications", force: :cascade do |t|
    t.integer  "laboratory_id", limit: 4
    t.string   "name",          limit: 255
    t.text     "description",   limit: 65535
    t.integer  "status",        limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "laboratory_services", force: :cascade do |t|
    t.integer  "laboratory_id",                        limit: 4
    t.integer  "service_type_id",                      limit: 4
    t.text     "name",                                 limit: 16777215
    t.text     "description",                          limit: 16777215
    t.datetime "created_at",                                                                                     null: false
    t.datetime "updated_at",                                                                                     null: false
    t.decimal  "internal_cost",                                         precision: 10, scale: 2
    t.integer  "is_catalog",                           limit: 4,                                 default: 0
    t.decimal  "sale_price",                                            precision: 10, scale: 2
    t.integer  "is_exclusive_vinculacion",             limit: 4,                                 default: 0
    t.decimal  "evaluation_cost",                                       precision: 10, scale: 2
    t.integer  "status",                               limit: 4,                                 default: 0
    t.integer  "laboratory_service_classification_id", limit: 4,                                 default: 0
    t.boolean  "show_web",                             limit: 1,                                 default: false
  end

  add_index "laboratory_services", ["laboratory_id"], name: "index_laboratory_services_on_laboratory_id", using: :btree
  add_index "laboratory_services", ["service_type_id"], name: "index_laboratory_services_on_service_type_id", using: :btree

  create_table "maintenances", force: :cascade do |t|
    t.integer  "equipment_id",     limit: 4
    t.integer  "provider_id",      limit: 4
    t.string   "name",             limit: 255
    t.string   "purchase_request", limit: 255
    t.text     "description",      limit: 65535
    t.string   "status",           limit: 255,   default: "1"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "material_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.string   "status",      limit: 255,      default: "1"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.text     "description",      limit: 16777215
    t.integer  "unit_id",          limit: 4
    t.decimal  "unit_price",                        precision: 6, scale: 2
    t.string   "status",           limit: 255,                              default: "1"
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.string   "cas",              limit: 255
    t.string   "formula",          limit: 255
    t.integer  "material_type_id", limit: 4
  end

  create_table "miguel_fix", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4
  end

  create_table "oldtype", id: false, force: :cascade do |t|
    t.integer "id",  limit: 4, default: 0, null: false
    t.integer "old", limit: 4
  end

  create_table "other_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 16777215
    t.string   "status",      limit: 255,      default: "1"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "pedro_fix", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                default: 0, null: false
    t.integer  "requested_service_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_wage",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.integer  "participation",        limit: 4
  end

  create_table "precios_servicios", id: false, force: :cascade do |t|
    t.integer "id",             limit: 4,                                 default: 0,   null: false
    t.text    "servicio",       limit: 16777215
    t.integer "es_vinculacion", limit: 4,                                 default: 0
    t.decimal "precio_venta",                    precision: 10, scale: 2, default: 0.0, null: false
    t.decimal "precio_interno",                  precision: 36, scale: 4, default: 0.0, null: false
  end

  create_table "project_quote_equipments", force: :cascade do |t|
    t.integer  "project_quote_id", limit: 4
    t.integer  "equipment_id",     limit: 4
    t.decimal  "hours",                          precision: 4, scale: 2
    t.decimal  "hourly_rate",                    precision: 6, scale: 2
    t.text     "details",          limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "project_quote_others", force: :cascade do |t|
    t.integer  "project_quote_id", limit: 4
    t.integer  "other_type_id",    limit: 4
    t.string   "concept",          limit: 255
    t.text     "details",          limit: 65535
    t.decimal  "quantity",                       precision: 4, scale: 2
    t.decimal  "price",                          precision: 6, scale: 2
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "project_quote_services", force: :cascade do |t|
    t.integer  "project_quote_id",      limit: 4
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "quantity",              limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "project_quote_technicians", force: :cascade do |t|
    t.integer  "project_quote_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.decimal  "hours",                          precision: 4, scale: 2
    t.decimal  "hourly_wage",                    precision: 6, scale: 2
    t.text     "details",          limit: 65535
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  create_table "project_quotes", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "consecutive",        limit: 4
    t.string   "number",             limit: 20
    t.text     "details",            limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "providers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.string   "email",      limit: 255
    t.text     "address",    limit: 65535
    t.integer  "status",     limit: 4,     default: 1
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "repduarte", id: false, force: :cascade do |t|
    t.datetime "created_at"
    t.string   "nombre",          limit: 511
    t.integer  "id",              limit: 4,        default: 0, null: false
    t.string   "number",          limit: 20
    t.integer  "request_type_id", limit: 4
    t.string   "laboratorio",     limit: 255
    t.text     "servicio",        limit: 16777215
    t.text     "request_link",    limit: 65535
    t.text     "description",     limit: 16777215
    t.integer  "quantity",        limit: 4
  end

  create_table "request_types", force: :cascade do |t|
    t.string   "short_name",    limit: 20
    t.string   "name",          limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "prefix",        limit: 255
    t.integer  "is_selectable", limit: 4,   default: 0
  end

  create_table "requested_service_additionals", force: :cascade do |t|
    t.integer  "requested_service_id_id",          limit: 4
    t.integer  "laboratory_service_additional_id", limit: 4
    t.string   "name",                             limit: 255
    t.text     "value",                            limit: 65535
    t.datetime "created_at",                                                 null: false
    t.datetime "updated_at",                                                 null: false
    t.integer  "position",                         limit: 4,     default: 0
  end

  create_table "requested_service_equipments", force: :cascade do |t|
    t.integer  "requested_service_id", limit: 4
    t.integer  "equipment_id",         limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_rate",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
  end

  add_index "requested_service_equipments", ["equipment_id"], name: "index_requested_service_equipments_on_equipment_id", using: :btree
  add_index "requested_service_equipments", ["requested_service_id"], name: "index_requested_service_equipments_on_requested_service_id", using: :btree

  create_table "requested_service_materials", force: :cascade do |t|
    t.integer  "requested_service_id", limit: 4
    t.integer  "material_id",          limit: 4
    t.decimal  "quantity",                              precision: 10, scale: 4
    t.decimal  "unit_price",                            precision: 6,  scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
  end

  add_index "requested_service_materials", ["material_id"], name: "index_requested_service_materials_on_material_id", using: :btree
  add_index "requested_service_materials", ["requested_service_id"], name: "index_requested_service_materials_on_requested_service_id", using: :btree

  create_table "requested_service_others", force: :cascade do |t|
    t.integer  "requested_service_id", limit: 4
    t.string   "concept",              limit: 255
    t.text     "details",              limit: 16777215
    t.decimal  "price",                                 precision: 10, scale: 2
    t.datetime "created_at",                                                     null: false
    t.datetime "updated_at",                                                     null: false
    t.integer  "other_type_id",        limit: 4
  end

  add_index "requested_service_others", ["requested_service_id"], name: "index_requested_service_others_on_requested_service_id", using: :btree

  create_table "requested_service_technicians", force: :cascade do |t|
    t.integer  "requested_service_id", limit: 4
    t.integer  "user_id",              limit: 4
    t.decimal  "hours",                                 precision: 6, scale: 2
    t.decimal  "hourly_wage",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.integer  "participation",        limit: 4
  end

  add_index "requested_service_technicians", ["requested_service_id"], name: "index_requested_service_technicians_on_requested_service_id", using: :btree
  add_index "requested_service_technicians", ["user_id"], name: "index_requested_service_technicians_on_user_id", using: :btree

  create_table "requested_services", force: :cascade do |t|
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "sample_id",             limit: 4
    t.integer  "consecutive",           limit: 4
    t.string   "number",                limit: 20
    t.text     "details",               limit: 16777215
    t.integer  "user_id",               limit: 4
    t.integer  "suggested_user_id",     limit: 4
    t.string   "status",                limit: 255,      default: "1"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "from_id",               limit: 4
    t.integer  "service_quote_type",    limit: 4
    t.integer  "cedula_id",             limit: 4,        default: 0
  end

  add_index "requested_services", ["laboratory_service_id"], name: "index_requested_services_on_laboratory_service_id", using: :btree
  add_index "requested_services", ["sample_id"], name: "index_requested_services_on_sample_id", using: :btree
  add_index "requested_services", ["suggested_user_id"], name: "index_requested_services_on_suggested_user_id", using: :btree
  add_index "requested_services", ["user_id"], name: "index_requested_services_on_user_id", using: :btree

  create_table "rs", id: false, force: :cascade do |t|
    t.integer  "id",                    limit: 4,        default: 0,   null: false
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "sample_id",             limit: 4
    t.integer  "consecutive",           limit: 4
    t.string   "number",                limit: 20
    t.text     "details",               limit: 16777215
    t.integer  "user_id",               limit: 4
    t.integer  "suggested_user_id",     limit: 4
    t.string   "status",                limit: 255,      default: "1"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "from_id",               limit: 4
    t.integer  "service_quote_type",    limit: 4
  end

  create_table "rx", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "sample_details", force: :cascade do |t|
    t.integer  "sample_id",             limit: 4
    t.integer  "consecutive",           limit: 4
    t.string   "client_identification", limit: 255
    t.text     "notes",                 limit: 65535
    t.string   "status",                limit: 255,   default: "1"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "samples", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "consecutive",        limit: 4
    t.string   "number",             limit: 20
    t.string   "identification",     limit: 255
    t.text     "description",        limit: 16777215
    t.string   "status",             limit: 255,      default: "1"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "quantity",           limit: 4
    t.string   "code",               limit: 255
    t.integer  "system_id",          limit: 4
  end

  add_index "samples", ["service_request_id"], name: "index_samples_on_service_request_id", using: :btree

  create_table "sdi2016", id: false, force: :cascade do |t|
    t.string  "A",           limit: 255
    t.integer "dprCodigo",   limit: 2,   default: 0
    t.string  "dprUHCodigo", limit: 10
    t.string  "B",           limit: 255
    t.string  "dseEMail",    limit: 255
    t.string  "C",           limit: 255
  end

  create_table "sdi2017", id: false, force: :cascade do |t|
    t.string "A", limit: 255
    t.string "B", limit: 255
    t.string "C", limit: 255
  end

  create_table "sdi2017xx", id: false, force: :cascade do |t|
    t.string "A",           limit: 255
    t.string "B",           limit: 255
    t.string "C",           limit: 255
    t.string "dprUHCodigo", limit: 10
    t.string "dseEmail",    limit: 255
  end

  create_table "serv1589", id: false, force: :cascade do |t|
    t.integer  "id",                          limit: 4,                                 default: 0, null: false
    t.integer  "user_id",                     limit: 4
    t.string   "number",                      limit: 20
    t.integer  "request_type_id",             limit: 4
    t.text     "request_link",                limit: 65535
    t.text     "description",                 limit: 16777215
    t.integer  "status",                      limit: 4,                                 default: 1
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.integer  "supervisor_id",               limit: 4
    t.integer  "consecutive",                 limit: 4
    t.string   "system_id",                   limit: 255
    t.integer  "system_status",               limit: 4,                                 default: 1
    t.integer  "system_request_id",           limit: 4
    t.integer  "vinculacion_client_id",       limit: 4
    t.string   "vinculacion_client_name",     limit: 255
    t.string   "vinculacion_delivery",        limit: 255
    t.date     "vinculacion_start_date"
    t.date     "vinculacion_end_date"
    t.integer  "vinculacion_days",            limit: 4
    t.string   "vinculacion_client_contact",  limit: 255
    t.string   "vinculacion_client_email",    limit: 255
    t.string   "vinculacion_client_phone",    limit: 255
    t.decimal  "suggested_price",                              precision: 10, scale: 2
    t.string   "vinculacion_client_address1", limit: 255
    t.string   "vinculacion_client_address2", limit: 255
    t.string   "vinculacion_client_city",     limit: 255
    t.string   "vinculacion_client_state",    limit: 255
    t.string   "vinculacion_client_country",  limit: 255
    t.string   "vinculacion_client_zip",      limit: 255
    t.integer  "estimated_time",              limit: 4,                                 default: 0
    t.string   "vinculacion_hash",            limit: 255
  end

  create_table "service_files", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.integer  "service_request_id",   limit: 4
    t.integer  "sample_id",            limit: 4
    t.integer  "requested_service_id", limit: 4
    t.integer  "file_type",            limit: 4
    t.string   "description",          limit: 255
    t.string   "file",                 limit: 255
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "status",               limit: 4,   default: 1
  end

  add_index "service_files", ["requested_service_id"], name: "index_service_files_on_requested_service_id", using: :btree
  add_index "service_files", ["sample_id"], name: "index_service_files_on_sample_id", using: :btree
  add_index "service_files", ["service_request_id"], name: "index_service_files_on_service_request_id", using: :btree
  add_index "service_files", ["user_id"], name: "index_service_files_on_user_id", using: :btree

  create_table "service_request_participations", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "user_id",            limit: 4
    t.integer  "percentage",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_requests", force: :cascade do |t|
    t.integer  "user_id",                     limit: 4
    t.string   "number",                      limit: 20
    t.integer  "request_type_id",             limit: 4
    t.text     "request_link",                limit: 65535
    t.text     "description",                 limit: 16777215
    t.integer  "status",                      limit: 4,                                 default: 1
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.integer  "supervisor_id",               limit: 4
    t.integer  "consecutive",                 limit: 4
    t.string   "system_id",                   limit: 255
    t.integer  "system_status",               limit: 4,                                 default: 1
    t.integer  "system_request_id",           limit: 4
    t.integer  "vinculacion_client_id",       limit: 4
    t.string   "vinculacion_client_name",     limit: 255
    t.string   "vinculacion_delivery",        limit: 255
    t.date     "vinculacion_start_date"
    t.date     "vinculacion_end_date"
    t.integer  "vinculacion_days",            limit: 4
    t.string   "vinculacion_client_contact",  limit: 255
    t.string   "vinculacion_client_email",    limit: 255
    t.string   "vinculacion_client_phone",    limit: 255
    t.decimal  "suggested_price",                              precision: 10, scale: 2
    t.string   "vinculacion_client_address1", limit: 255
    t.string   "vinculacion_client_address2", limit: 255
    t.string   "vinculacion_client_city",     limit: 255
    t.string   "vinculacion_client_state",    limit: 255
    t.string   "vinculacion_client_country",  limit: 255
    t.string   "vinculacion_client_zip",      limit: 255
    t.integer  "estimated_time",              limit: 4,                                 default: 0
    t.string   "vinculacion_hash",            limit: 255
  end

  add_index "service_requests", ["request_type_id"], name: "index_service_requests_on_request_type_id", using: :btree
  add_index "service_requests", ["supervisor_id"], name: "index_service_requests_on_supervisor_id", using: :btree
  add_index "service_requests", ["user_id"], name: "index_service_requests_on_user_id", using: :btree

  create_table "service_types", force: :cascade do |t|
    t.string   "short_name", limit: 20
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "servicios_metrologia", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4,                                 default: 0,   null: false
    t.integer "system_request_id",    limit: 4
    t.string  "number",               limit: 20
    t.string  "razon_social",         limit: 255
    t.text    "descripcion",          limit: 16777215
    t.string  "magnitud",             limit: 255
    t.text    "name",                 limit: 16777215
    t.decimal "precio_venta",                          precision: 10, scale: 2, default: 0.0
  end

  create_table "sintipo", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0, null: false
  end

  create_table "sintipo2", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0
  end

  create_table "sintipo3", id: false, force: :cascade do |t|
    t.integer "id", limit: 4, default: 0
  end

  create_table "srbak", id: false, force: :cascade do |t|
    t.integer  "id",                          limit: 4,                                 default: 0, null: false
    t.integer  "user_id",                     limit: 4
    t.string   "number",                      limit: 20
    t.integer  "request_type_id",             limit: 4
    t.string   "request_link",                limit: 255
    t.text     "description",                 limit: 16777215
    t.integer  "status",                      limit: 4,                                 default: 1
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.integer  "supervisor_id",               limit: 4
    t.integer  "consecutive",                 limit: 4
    t.string   "system_id",                   limit: 255
    t.integer  "system_status",               limit: 4,                                 default: 1
    t.integer  "system_request_id",           limit: 4
    t.integer  "vinculacion_client_id",       limit: 4
    t.string   "vinculacion_client_name",     limit: 255
    t.string   "vinculacion_delivery",        limit: 255
    t.date     "vinculacion_start_date"
    t.date     "vinculacion_end_date"
    t.integer  "vinculacion_days",            limit: 4
    t.string   "vinculacion_client_contact",  limit: 255
    t.string   "vinculacion_client_email",    limit: 255
    t.string   "vinculacion_client_phone",    limit: 255
    t.decimal  "suggested_price",                              precision: 10, scale: 2
    t.string   "vinculacion_client_address1", limit: 255
    t.string   "vinculacion_client_address2", limit: 255
    t.string   "vinculacion_client_city",     limit: 255
    t.string   "vinculacion_client_state",    limit: 255
    t.string   "vinculacion_client_country",  limit: 255
    t.string   "vinculacion_client_zip",      limit: 255
    t.integer  "estimated_time",              limit: 4,                                 default: 0
  end

  create_table "states", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "code",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "stu", id: false, force: :cascade do |t|
    t.string "x", limit: 255
    t.string "n", limit: 50,  null: false
    t.string "p", limit: 50,  null: false
    t.string "s", limit: 255
    t.string "c", limit: 255
  end

  create_table "stu2", id: false, force: :cascade do |t|
    t.string  "e",   limit: 255
    t.integer "eid", limit: 4,   default: 0
    t.string  "a",   limit: 255
    t.integer "aid", limit: 4,   default: 0
  end

  create_table "temp2", id: false, force: :cascade do |t|
    t.integer  "laboratory_id",         limit: 4
    t.integer  "requested_service_id",  limit: 4
    t.string   "number",                limit: 20
    t.string   "name",                  limit: 255
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "user_id",               limit: 4
    t.datetime "ST1"
    t.datetime "ST2"
    t.datetime "ST3"
    t.datetime "ST4"
    t.datetime "ST5"
    t.datetime "ST6"
    t.datetime "ST7"
    t.datetime "ST8"
    t.datetime "ST99"
  end

  create_table "units", force: :cascade do |t|
    t.string   "short_name", limit: 10
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",            limit: 255
    t.string   "employee_number",  limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.decimal  "hourly_wage",                  precision: 6, scale: 2
    t.string   "access",           limit: 255,                         default: "1"
    t.string   "status",           limit: 255,                         default: "1"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "supervisor1_id",   limit: 4
    t.integer  "supervisor2_id",   limit: 4
    t.boolean  "require_auth",     limit: 1,                           default: false
    t.integer  "business_unit_id", limit: 4,                           default: 1
    t.integer  "department_id",    limit: 4,                           default: 0
  end

  add_index "users", ["supervisor1_id"], name: "index_users_on_supervisor1_id", using: :btree
  add_index "users", ["supervisor2_id"], name: "index_users_on_supervisor2_id", using: :btree

  create_table "users_160831", id: false, force: :cascade do |t|
    t.integer  "id",               limit: 4,                           default: 0,     null: false
    t.string   "email",            limit: 255
    t.string   "employee_number",  limit: 255
    t.string   "first_name",       limit: 255
    t.string   "last_name",        limit: 255
    t.decimal  "hourly_wage",                  precision: 6, scale: 2
    t.string   "access",           limit: 255,                         default: "1"
    t.string   "status",           limit: 255,                         default: "1"
    t.datetime "created_at",                                                           null: false
    t.datetime "updated_at",                                                           null: false
    t.integer  "supervisor1_id",   limit: 4
    t.integer  "supervisor2_id",   limit: 4
    t.boolean  "require_auth",     limit: 1,                           default: false
    t.integer  "business_unit_id", limit: 4,                           default: 1
  end

  create_table "xc", id: false, force: :cascade do |t|
    t.integer  "id",         limit: 4,        default: 0,   null: false
    t.string   "number",     limit: 20
    t.text     "details",    limit: 16777215
    t.string   "status",     limit: 255,      default: "1"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "xrse", id: false, force: :cascade do |t|
    t.integer  "id",                   limit: 4,                                default: 0, null: false
    t.integer  "requested_service_id", limit: 4
    t.integer  "equipment_id",         limit: 4
    t.decimal  "hours",                                 precision: 4, scale: 2
    t.decimal  "hourly_rate",                           precision: 6, scale: 2
    t.text     "details",              limit: 16777215
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
  end

  create_table "xx", id: false, force: :cascade do |t|
    t.integer  "id",         limit: 4,        default: 0,   null: false
    t.string   "number",     limit: 20
    t.text     "details",    limit: 16777215
    t.string   "status",     limit: 255,      default: "1"
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "xxx", id: false, force: :cascade do |t|
    t.integer  "id",                    limit: 4,        default: 0,   null: false
    t.integer  "laboratory_service_id", limit: 4
    t.integer  "sample_id",             limit: 4
    t.integer  "consecutive",           limit: 4
    t.string   "number",                limit: 20
    t.text     "details",               limit: 16777215
    t.integer  "user_id",               limit: 4
    t.integer  "suggested_user_id",     limit: 4
    t.string   "status",                limit: 255,      default: "1"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.integer  "from_id",               limit: 4
  end

  create_table "xxyyzz", id: false, force: :cascade do |t|
    t.integer "requested_service_id", limit: 4
    t.string  "email",                limit: 255
    t.integer "reguser",              limit: 4
    t.integer "assuser",              limit: 4
    t.decimal "regh",                             precision: 6, scale: 2
    t.decimal "assh",                             precision: 6, scale: 2
  end

end
