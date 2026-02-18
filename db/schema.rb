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

ActiveRecord::Schema[8.1].define(version: 2026_02_18_224031) do
  create_table "addresses", force: :cascade do |t|
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "state", null: false
    t.datetime "updated_at", null: false
    t.integer "vet_office_id", null: false
    t.string "zipcode", null: false
    t.index ["vet_office_id"], name: "index_addresses_on_vet_office_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.string "contact_type", null: false
    t.string "contact_value", null: false
    t.datetime "created_at", null: false
    t.boolean "is_primary", default: false
    t.datetime "updated_at", null: false
    t.integer "vet_office_id", null: false
    t.index ["vet_office_id", "contact_type", "is_primary"], name: "idx_on_vet_office_id_contact_type_is_primary_eec3e1dd41"
    t.index ["vet_office_id"], name: "index_contacts_on_vet_office_id"
  end

  create_table "dismissed_alerts", force: :cascade do |t|
    t.string "alert_condition", null: false
    t.string "alert_type", null: false
    t.datetime "created_at", null: false
    t.datetime "dismissed_at", null: false
    t.integer "pet_id", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "alert_type", "alert_condition"], name: "index_dismissed_alerts_on_pet_type_condition"
    t.index ["pet_id"], name: "index_dismissed_alerts_on_pet_id"
  end

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

  create_table "medication_dosages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "dose", precision: 10, scale: 2, null: false
    t.integer "medication_id", null: false
    t.text "notes"
    t.date "recorded_on", null: false
    t.datetime "updated_at", null: false
    t.index ["medication_id", "recorded_on"], name: "index_medication_dosages_on_medication_id_and_recorded_on"
    t.index ["medication_id"], name: "index_medication_dosages_on_medication_id"
  end

  create_table "medications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "dose", precision: 10, scale: 2, null: false
    t.date "end_date"
    t.string "medication_name", null: false
    t.text "notes"
    t.integer "pet_id", null: false
    t.date "start_date", null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "start_date"], name: "index_medications_on_pet_id_and_start_date"
    t.index ["pet_id"], name: "index_medications_on_pet_id"
  end

  create_table "pet_health_thresholds", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "pet_id", null: false
    t.string "threshold_type", null: false
    t.decimal "threshold_value", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["pet_id", "threshold_type"], name: "index_pet_health_thresholds_on_pet_id_and_threshold_type", unique: true
    t.index ["pet_id"], name: "index_pet_health_thresholds_on_pet_id"
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

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "rating_value", null: false
    t.text "review_text"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.integer "veterinarian_id", null: false
    t.index ["user_id", "veterinarian_id"], name: "index_ratings_on_user_id_and_veterinarian_id", unique: true
    t.index ["user_id"], name: "index_ratings_on_user_id"
    t.index ["veterinarian_id"], name: "index_ratings_on_veterinarian_id"
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

  create_table "vet_offices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "veterinarians", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "vet_office_id", null: false
    t.text "work_history"
    t.integer "years_of_experience"
    t.index ["vet_office_id"], name: "index_veterinarians_on_vet_office_id"
  end

  add_foreign_key "addresses", "vet_offices"
  add_foreign_key "contacts", "vet_offices"
  add_foreign_key "dismissed_alerts", "pets"
  add_foreign_key "health_records", "medications"
  add_foreign_key "health_records", "pets"
  add_foreign_key "medication_dosages", "medications"
  add_foreign_key "medications", "pets"
  add_foreign_key "pet_health_thresholds", "pets"
  add_foreign_key "pets", "users"
  add_foreign_key "ratings", "users"
  add_foreign_key "ratings", "veterinarians"
  add_foreign_key "reminders", "pets"
  add_foreign_key "veterinarians", "vet_offices"
end
