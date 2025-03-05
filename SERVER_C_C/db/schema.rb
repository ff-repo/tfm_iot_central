# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_02_21_020602) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_tokens", force: :cascade do |t|
    t.string "token"
    t.string "description"
    t.boolean "active", default: false
    t.string "entity_type"
    t.bigint "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_type", "entity_id"], name: "index_api_tokens_on_entity"
  end

  create_table "bot_command_pools", force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.string "command"
    t.json "metadata"
    t.json "result"
    t.datetime "sent_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_bot_command_pools_on_bot_id"
  end

  create_table "bot_settings", force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.json "config"
    t.json "crypt_config"
    t.json "bot_client_config"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bot_id"], name: "index_bot_settings_on_bot_id"
  end

  create_table "bot_statuses", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bot_tracks", force: :cascade do |t|
    t.bigint "bot_id", null: false
    t.datetime "last_action", precision: nil
    t.string "ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "kind"
    t.index ["bot_id"], name: "index_bot_tracks_on_bot_id"
  end

  create_table "bots", force: :cascade do |t|
    t.string "code"
    t.string "machine_id"
    t.string "description"
    t.boolean "active", default: false
    t.string "os_type"
    t.string "os_version"
    t.bigint "bot_status_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "client_gateway_id"
    t.index ["bot_status_id"], name: "index_bots_on_bot_status_id"
    t.index ["client_gateway_id"], name: "index_bots_on_client_gateway_id"
    t.index ["code"], name: "index_bots_on_code", unique: true
  end

  create_table "client_gateway_tracks", force: :cascade do |t|
    t.bigint "client_gateway_id", null: false
    t.string "event_description"
    t.string "event_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_gateway_id"], name: "index_client_gateway_tracks_on_client_gateway_id"
  end

  create_table "client_gateways", force: :cascade do |t|
    t.string "description"
    t.string "code"
    t.datetime "implemented_at", precision: nil
    t.string "requester_email"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "domain"
    t.string "external_app_code"
    t.json "cc_setting"
    t.json "client_setting"
    t.json "user_setting"
    t.integer "bot_size", default: 0
    t.datetime "terminated_at", precision: nil
    t.index ["code"], name: "index_client_gateways_on_code", unique: true
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "facade_news", force: :cascade do |t|
    t.string "title"
    t.string "marker"
    t.json "details"
    t.json "crypt_config", default: {}
    t.string "app_link"
    t.boolean "active", default: false
    t.datetime "published_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti"
  end

  create_table "notifiers", force: :cascade do |t|
    t.string "uri"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "parameters", force: :cascade do |t|
    t.string "code"
    t.string "description"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_parameters_on_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bot_command_pools", "bots"
  add_foreign_key "bot_settings", "bots"
  add_foreign_key "bot_tracks", "bots"
  add_foreign_key "bots", "bot_statuses"
  add_foreign_key "bots", "client_gateways"
  add_foreign_key "client_gateway_tracks", "client_gateways"
end
