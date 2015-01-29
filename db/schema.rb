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

ActiveRecord::Schema.define(version: 20150128172044) do

  create_table "categories", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "features", force: :cascade do |t|
    t.text     "name"
    t.text     "tag_list"
    t.text     "tag_item_title"
    t.text     "tag_item_link"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "items", force: :cascade do |t|
    t.text     "name"
    t.text     "link"
    t.text     "content"
    t.text     "price"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "link_id"
    t.integer  "page_id"
    t.integer  "category_id"
    t.integer  "task_id"
  end

  create_table "links", force: :cascade do |t|
    t.text     "name"
    t.text     "source_url"
    t.integer  "page_id"
    t.integer  "category_id"
    t.integer  "feature_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "status",      default: 0
  end

  create_table "pages", force: :cascade do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "task_logs", force: :cascade do |t|
    t.integer  "task_id"
    t.integer  "total"
    t.integer  "error"
    t.integer  "success"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.text     "name"
    t.integer  "page_id"
    t.integer  "category_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "status",      default: 0
    t.string   "min"
    t.string   "hour"
    t.string   "day"
    t.string   "month"
    t.string   "week"
    t.datetime "started_at"
    t.datetime "finished_at"
  end

end
