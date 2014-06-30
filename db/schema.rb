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

ActiveRecord::Schema.define(version: 20140629202438) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "concert_sets", force: true do |t|
    t.integer  "show_id"
    t.string   "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "position"
  end

  create_table "rails_admin_histories", force: true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      limit: 2
    t.integer  "year",       limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], name: "index_rails_admin_histories", using: :btree

  create_table "section_markers", force: true do |t|
    t.string   "title"
    t.integer  "position"
    t.integer  "track_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shows", force: true do |t|
    t.date     "show_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "location"
    t.boolean  "remastered",  default: false
    t.boolean  "sbd",         default: false
    t.text     "source_info"
  end

  add_index "shows", ["show_date"], name: "shows_show_date_index", using: :btree

  create_table "songs", force: true do |t|
    t.string   "title"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "slug"
    t.integer  "tracks_count", default: 0
  end

  create_table "songs_tracks", force: true do |t|
    t.integer "song_id"
    t.integer "track_id"
  end

  add_index "songs_tracks", ["song_id"], name: "songs_tracks_song_id_index", using: :btree

  create_table "tracks", force: true do |t|
    t.integer  "show_id"
    t.string   "title"
    t.integer  "position"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "song_file_file_name"
    t.string   "song_file_content_type"
    t.integer  "song_file_file_size"
    t.datetime "song_file_updated_at"
    t.integer  "duration"
    t.string   "slug"
    t.integer  "concert_set_id"
    t.json     "map"
    t.string   "song_file_m4a_file_name"
    t.string   "song_file_m4a_content_type"
    t.integer  "song_file_m4a_file_size"
    t.datetime "song_file_m4a_updated_at"
    t.string   "song_file_ogx_file_name"
    t.string   "song_file_ogx_content_type"
    t.integer  "song_file_ogx_file_size"
    t.datetime "song_file_ogx_updated_at"
  end

  add_index "tracks", ["slug"], name: "index_tracks_on_slug", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
