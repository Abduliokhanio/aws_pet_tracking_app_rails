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

ActiveRecord::Schema[8.1].define(version: 2026_02_18_184158) do
  create_table "health_records", force: :cascade do |t|
    t.string "activity_level"
    t.datetime "created_at", null: false
    t.string "food_intake"
    t.string "medication_dose"
    t.integer "medication_id"
    t.string "medication_name"
    t.string "mood"
    t.text "notes"
    t.integer "pet_id", null: false
    t.date "recorded_on", null: false
    t.string "status"
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 5, scale: 2
    t.index ["medication_id"], name: "index_health_records_on_medication_id"
    t.index ["pet_id", "recorded_on"], name: "index_health_records_on_pet_id_and_recorded_on"
    t.index ["pet_id"], name: "index_health_records_on_pet_id"
    t.index ["recorded_on"], name: "index_health_records_on_recorded_on"
  end

  create_table "medications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dose", null: false
    t.date "end_date"
    t.string "medication_name", null: false
    t.text "notes"
    t.integer "pet_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "start_date"], name: "index_medications_on_pet_id_and_start_date"
    t.index ["pet_id"], name: "index_medications_on_pet_id"
  end

  create_table "pets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "gender"
    t.string "name"
    t.string "species"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_pets_on_user_id"
  end

  create_table "reminders", force: :cascade do |t|
    t.text "alert_context"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "pet_id", null: false
    t.string "reminder_type", null: false
    t.date "scheduled_date", null: false
    t.string "status", default: "pending"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "scheduled_date"], name: "index_reminders_on_pet_id_and_scheduled_date"
    t.index ["pet_id"], name: "index_reminders_on_pet_id"
    t.index ["status"], name: "index_reminders_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "gender"
    t.string "name"
    t.string "ssn"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "health_records", "medications"
  add_foreign_key "health_records", "pets"
  add_foreign_key "medications", "pets"
  add_foreign_key "pets", "users"
  add_foreign_key "reminders", "pets"
end
