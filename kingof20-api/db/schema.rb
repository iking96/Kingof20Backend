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

ActiveRecord::Schema.define(version: 2019_09_15_041220) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_queue_entries", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_game_queue_entries_on_game_id"
    t.index ["user_id"], name: "index_game_queue_entries_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.integer "board", array: true
    t.integer "initiator_score"
    t.integer "initiator_rack", array: true
    t.integer "opponent_score"
    t.integer "opponent_rack", array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "initiator_id"
    t.bigint "opponent_id"
    t.bigint "current_player_id"
    t.integer "available_tiles", array: true
    t.boolean "complete", default: false
    t.index ["current_player_id"], name: "index_games_on_current_player_id"
    t.index ["initiator_id"], name: "index_games_on_initiator_id"
    t.index ["opponent_id"], name: "index_games_on_opponent_id"
  end

  create_table "moves", force: :cascade do |t|
    t.integer "row_num", array: true
    t.integer "col_num", array: true
    t.integer "tile_value", array: true
    t.bigint "user_id"
    t.bigint "game_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "move_number"
    t.index ["game_id"], name: "index_moves_on_game_id"
    t.index ["user_id"], name: "index_moves_on_user_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "game_queue_entries", "games"
  add_foreign_key "game_queue_entries", "users"
  add_foreign_key "games", "users", column: "current_player_id"
  add_foreign_key "games", "users", column: "initiator_id"
  add_foreign_key "games", "users", column: "opponent_id"
  add_foreign_key "moves", "games"
  add_foreign_key "moves", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
end
