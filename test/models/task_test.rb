require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @demo = DemoSession.start!
    @task = @demo.tasks.new(title: "テスト", priority: "medium", status: "todo")
  end

  test "creates a valid task" do
    assert_difference "Task.count", 1 do
      assert @task.save
    end
  end

  test "requires title and caps its length" do
    [nil, " ", "あ" * 101].each do |title|
      @task.title = title
      assert_not @task.valid?
      assert @task.errors[:title].any?
    end
  end

  test "rejects unsupported priority and status" do
    @task.priority = "urgent"
    @task.status = "archived"
    assert_not @task.valid?
    assert @task.errors[:priority].any?
    assert @task.errors[:status].any?
  end

  test "validates optional ISO date including impossible dates" do
    ["tomorrow", "2026-02-30", "2026-13-01", "2026-01-01garbage"].each do |date|
      @task.due_date = date
      assert_not @task.valid?, date
    end
    ["", "2026-10-30", Date.current].each do |date|
      @task.due_date = date
      assert @task.valid?, date.to_s
    end
  end

  test "supports all status transitions and rejects unknown states without persisting" do
    @task.save!
    %w[in_progress done todo].each do |status|
      assert @task.transition_to(status)
      assert_equal status, @task.reload.status
    end
    assert_not @task.transition_to("unknown")
    assert_equal "todo", @task.reload.status
  end

  test "overdue excludes done tasks and today" do
    @task.update!(due_date: Date.yesterday)
    assert @task.overdue?
    assert_includes @demo.tasks.overdue, @task
    @task.transition_to("done")
    assert_not @task.overdue?
    assert_not_includes @demo.tasks.overdue, @task
    @task.update!(status: "todo", due_date: Date.current)
    assert_not @task.overdue?
  end

  test "database rejects invalid enum even when bypassing validation" do
    @task.save!
    assert_raises(ActiveRecord::StatementInvalid) { @task.update_column(:status, "invalid") }
  end
end
