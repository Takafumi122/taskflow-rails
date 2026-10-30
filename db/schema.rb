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

ActiveRecord::Schema[8.1].define(version: 2026_10_30_000000) do
  create_table "demo_sessions", force: :cascade do |t|
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_demo_sessions_on_expires_at"
    t.index ["token"], name: "index_demo_sessions_on_token", unique: true
  end

  create_table "tasks", force: :cascade do |t|
    t.integer "demo_session_id", null: false
    t.string "title", limit: 100, null: false
    t.text "description"
    t.string "status", default: "todo", null: false
    t.string "priority", default: "medium", null: false
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["demo_session_id", "due_date"], name: "index_tasks_on_demo_session_id_and_due_date"
    t.index ["demo_session_id", "priority"], name: "index_tasks_on_demo_session_id_and_priority"
    t.index ["demo_session_id", "status"], name: "index_tasks_on_demo_session_id_and_status"
    t.index ["demo_session_id"], name: "index_tasks_on_demo_session_id"
    t.check_constraint "length(title) BETWEEN 1 AND 100", name: "tasks_title_length"
    t.check_constraint "priority IN ('low', 'medium', 'high')", name: "tasks_priority_allowed"
    t.check_constraint "status IN ('todo', 'in_progress', 'done')", name: "tasks_status_allowed"
  end

  add_foreign_key "tasks", "demo_sessions"
end
