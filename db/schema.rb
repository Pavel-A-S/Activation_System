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

ActiveRecord::Schema.define(version: 20160330213008) do

  create_table "chats", force: :cascade do |t|
    t.text     "text"
    t.integer  "human_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text     "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "human_id"
    t.integer  "photo_id"
  end

  create_table "humans", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "password_digest"
    t.string   "avatar"
    t.string   "access"
    t.string   "human_card"
    t.string   "activation_token"
    t.string   "activation_status"
    t.datetime "activated_at"
    t.datetime "last_login"
    t.datetime "activation_request_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_requested_at"
  end

  create_table "photo_galleries", force: :cascade do |t|
    t.string   "description"
    t.string   "cover"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "human_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string   "name"
    t.string   "path"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "photo_gallery_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string   "activation_token"
    t.string   "activation_status"
    t.datetime "activation_request_at"
    t.datetime "activated_at"
    t.string   "name"
    t.string   "MAC"
    t.text     "body"
    t.integer  "user_id"
    t.boolean  "sended",                default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "avatar"
    t.string   "access"
    t.string   "human_card"
    t.string   "activation_token"
    t.string   "activation_status"
    t.datetime "activated_at"
    t.datetime "last_login"
    t.datetime "activation_request_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_requested_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
