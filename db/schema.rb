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

ActiveRecord::Schema.define(version: 20141009171839) do

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.text     "description"
    t.boolean  "is_private",  default: false
    t.boolean  "is_writable", default: false
    t.integer  "parent_id"
    t.integer  "group_id"
    t.boolean  "is_featured"
  end

  create_table "documents", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "description"
    t.boolean  "is_private",  default: true
    t.boolean  "is_writable", default: false
    t.integer  "category_id"
    t.integer  "user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "memberships", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
    t.integer  "user_id"
    t.integer  "level"
  end

  create_table "revisions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "document_id"
    t.integer  "user_id"
    t.integer  "position"
    t.integer  "download_count", default: 0
    t.string   "file_name"
    t.string   "file_type"
    t.integer  "file_size"
    t.binary   "file_data"
    t.text     "search_text"
    t.string   "doc_link"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "email"
    t.string   "full_name"
    t.boolean  "is_admin",   default: false
  end

end
