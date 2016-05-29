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

ActiveRecord::Schema.define(version: 20160529061311) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.string   "image"
    t.text     "description"
    t.integer  "order"
    t.string   "token"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "source_url"
  end

  add_index "attachments", ["imageable_type", "imageable_id"], name: "index_attachments_on_imageable_type_and_imageable_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "shop_id"
    t.integer  "parent_id"
    t.integer  "total"
    t.string   "jp_name"
    t.string   "zh_name"
    t.string   "code"
    t.string   "tipe"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "categories", ["parent_id"], name: "index_categories_on_parent_id", using: :btree
  add_index "categories", ["shop_id"], name: "index_categories_on_shop_id", using: :btree

  create_table "links", force: :cascade do |t|
    t.string   "value"
    t.date     "fetch_time"
    t.integer  "state",          default: 0
    t.integer  "fetchable_id"
    t.string   "fetchable_type"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "links", ["fetchable_type", "fetchable_id"], name: "index_links_on_fetchable_type_and_fetchable_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "jp_name"
    t.string   "zh_name"
    t.integer  "original_price"
    t.integer  "wholesale_price"
    t.integer  "stock"
    t.string   "item_code"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "attachments_count", default: 0
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree

  create_table "shops", force: :cascade do |t|
    t.string   "zh_name"
    t.string   "jp_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "categories", "shops"
  add_foreign_key "products", "categories"
end
