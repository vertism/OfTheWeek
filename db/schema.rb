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

ActiveRecord::Schema.define(:version => 20120119000226) do

  create_table "activities", :force => true do |t|
    t.integer  "photo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user"
  end

  create_table "photos", :force => true do |t|
    t.integer  "year"
    t.string   "url_square"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "week"
    t.string   "tag"
    t.string   "url_original"
    t.string   "url_thumbnail"
    t.integer  "views"
  end

  add_index "photos", ["tag"], :name => "index_photos_on_tag"
  add_index "photos", ["week"], :name => "index_photos_on_week"
  add_index "photos", ["year"], :name => "index_photos_on_year"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
