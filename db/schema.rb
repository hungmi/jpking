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

ActiveRecord::Schema.define(version: 20160614044800) do

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

  create_table "cart_items", force: :cascade do |t|
    t.integer  "cart_id"
    t.integer  "product_id"
    t.integer  "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "cart_items", ["cart_id"], name: "index_cart_items_on_cart_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "carts", ["user_id"], name: "index_carts_on_user_id", using: :btree

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

  create_table "order_items", force: :cascade do |t|
    t.integer  "order_id"
    t.integer  "product_id"
    t.string   "name"
    t.integer  "quantity"
    t.integer  "ordered_price"
    t.integer  "state"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "item_code"
  end

  add_index "order_items", ["order_id"], name: "index_order_items_on_order_id", using: :btree
  add_index "order_items", ["product_id"], name: "index_order_items_on_product_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.string   "token"
    t.string   "num"
    t.integer  "user_id"
    t.integer  "total"
    t.integer  "delivery"
    t.integer  "state",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "category_id"
    t.string   "jp_name"
    t.string   "zh_name",           default: ""
    t.integer  "original_price"
    t.integer  "wholesale_price"
    t.integer  "stock"
    t.string   "item_code"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "attachments_count", default: 0
    t.text     "material"
    t.text     "description"
    t.integer  "state",             default: 0
    t.string   "product_size"
    t.string   "origin"
    t.integer  "wholesale_amount",  default: 1
    t.boolean  "price_in_name",     default: false
    t.integer  "shop_id"
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["shop_id"], name: "index_products_on_shop_id", using: :btree

  create_table "shops", force: :cascade do |t|
    t.string   "zh_name"
    t.string   "jp_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "phone"
    t.string   "email"
    t.string   "password_digest"
    t.string   "password_confirmation"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "role",                  default: 0
  end

  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "products"
  add_foreign_key "carts", "users"
  add_foreign_key "categories", "shops"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "users"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "shops"
end
