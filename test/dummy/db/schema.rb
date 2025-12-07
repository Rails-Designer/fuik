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

ActiveRecord::Schema[8.1].define(version: 2025_01_01_000000) do
  create_table "fuik_webhook_events", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.text "error"
    t.string "event_id", null: false
    t.string "event_type", null: false
    t.json "headers", default: {}, null: false
    t.string "provider", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_fuik_webhook_events_on_created_at"
    t.index ["provider", "event_id"], name: "index_fuik_webhook_events_on_provider_and_event_id", unique: true
    t.index ["provider", "event_type"], name: "index_fuik_webhook_events_on_provider_and_event_type"
    t.index ["status"], name: "index_fuik_webhook_events_on_status"
  end
end
