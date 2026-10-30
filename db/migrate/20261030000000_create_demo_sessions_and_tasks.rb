class CreateDemoSessionsAndTasks < ActiveRecord::Migration[8.1]
  def change
    create_table :demo_sessions do |t|
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :demo_sessions, :token, unique: true
    add_index :demo_sessions, :expires_at
    create_table :tasks do |t|
      t.references :demo_session, null: false, foreign_key: true
      t.string :title, null: false, limit: 100
      t.text :description
      t.string :status, null: false, default: "todo"
      t.string :priority, null: false, default: "medium"
      t.date :due_date
      t.timestamps
    end
    add_index :tasks, [:demo_session_id, :status]
    add_index :tasks, [:demo_session_id, :priority]
    add_index :tasks, [:demo_session_id, :due_date]
    add_check_constraint :tasks, "status IN ('todo', 'in_progress', 'done')", name: "tasks_status_allowed"
    add_check_constraint :tasks, "priority IN ('low', 'medium', 'high')", name: "tasks_priority_allowed"
    add_check_constraint :tasks, "length(title) BETWEEN 1 AND 100", name: "tasks_title_length"
  end
end
