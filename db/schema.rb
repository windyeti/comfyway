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

ActiveRecord::Schema.define(version: 2021_12_30_214600) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  create_table "products", force: :cascade do |t|
    t.string "fid"
    t.string "title"
    t.string "url"
    t.string "sku"
    t.string "distributor"
    t.string "image"
    t.string "cat"
    t.string "cat1"
    t.decimal "price"
    t.integer "quantity"
    t.string "p1"
    t.string "desc"
    t.bigint "insales_id"
    t.bigint "insales_var_id"
    t.boolean "check", default: true
    t.string "barcode"
    t.string "cat2"
    t.string "cat3"
    t.string "cat4"
    t.string "cat5"
    t.string "video"
    t.string "currency"
    t.string "mtitle"
    t.string "mdesc"
    t.string "mkeywords"
    t.string "vendor"
    t.string "manual"
    t.string "preview_3d"
    t.string "foto"
    t.string "draft"
    t.string "model_3d"
    t.string "manuals"
    t.string "date_arrival"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "purchase_price"
    t.decimal "oldprice"
    t.string "sdesc"
    t.integer "quantity_add"
    t.boolean "insales_check", default: false
    t.boolean "deactivated", default: false
    t.string "weight"
    t.string "insales_link"
    t.string "insales_images"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name", null: false
    t.string "role", default: "User"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
