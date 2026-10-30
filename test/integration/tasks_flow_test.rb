require "test_helper"

class TasksFlowTest < ActionDispatch::IntegrationTest
  setup do
    get root_path
    assert_response :success
    @demo = DemoSession.order(:id).last
  end

  test "initial visit seeds once and displays board summary" do
    assert_select ".column", 3
    assert_select ".task-card", 7
    assert_select ".completion strong", text: /29/
    assert_no_difference "DemoSession.count" do
      get root_path
    end
  end

  test "creates shows edits and deletes a task" do
    get new_task_path
    assert_response :success
    assert_difference "@demo.tasks.count", 1 do
      post tasks_path, params: { task: { title: "新しいタスク", priority: "high", status: "todo", due_date: "2026-11-01" } }
    end
    assert_redirected_to root_path
    task = @demo.tasks.order(:id).last
    get task_path(task)
    assert_response :success
    get edit_task_path(task)
    assert_response :success
    patch task_path(task), params: { task: { title: "編集したタスク" } }
    assert_redirected_to task_path(task)
    assert_equal "編集したタスク", task.reload.title
    assert_difference "@demo.tasks.count", -1 do
      delete task_path(task)
    end
    assert_redirected_to root_path
  end

  test "invalid creation renders helpful errors" do
    assert_no_difference "Task.count" do
      post tasks_path, params: { task: { title: "", priority: "urgent", status: "invalid", due_date: "not-a-date" } }
    end
    assert_response :unprocessable_entity
    assert_select "[role=alert]", text: /入力内容を確認/
    assert_select "li", text: /タイトル/
  end

  test "invalid update preserves stored data" do
    task = @demo.tasks.first
    original = task.title
    patch task_path(task), params: { task: { title: "" } }
    assert_response :unprocessable_entity
    assert_equal original, task.reload.title
  end

  test "filters by status priority overdue and their intersection" do
    get root_path, params: { status_filter: "done" }
    assert_select ".task-card", 2
    get root_path, params: { priority_filter: "high" }
    assert_select ".task-card", 3
    get root_path, params: { overdue: "1" }
    assert_select ".task-card", 1
    get root_path, params: { status_filter: "todo", priority_filter: "medium", overdue: "1" }
    assert_select ".task-card", 1
    assert_select ".stat strong", text: /7/
    get root_path, params: { status_filter: "invalid", priority_filter: "invalid" }
    assert_select ".task-card", 7
  end

  test "status updates with turbo stream while preserving active filters" do
    task = @demo.tasks.find_by!(status: "todo", priority: "high")
    patch transition_task_path(task), params: { status: "done", status_filter: "todo" }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
    assert_equal "done", task.reload.status
    assert_select 'turbo-stream[target="workspace"]'
    assert_not_includes response.body, "id=\"task_#{task.id}\""
    patch transition_task_path(task), params: { status: "invalid" }
    assert_response :unprocessable_entity
    assert_equal "done", task.reload.status
  end

  test "other sessions cannot read edit update delete or transition a task" do
    other = open_session
    other.get root_path
    foreign_demo = DemoSession.order(:id).last
    assert_not_equal @demo.id, foreign_demo.id
    task = @demo.tasks.first
    other.get task_path(task)
    assert_equal 404, other.response.status
    other.get edit_task_path(task)
    assert_equal 404, other.response.status
    other.patch task_path(task), params: { task: { title: "hacked" } }
    assert_equal 404, other.response.status
    other.patch transition_task_path(task), params: { status: "done" }
    assert_equal 404, other.response.status
    assert_no_difference "Task.count" do
      other.delete task_path(task)
    end
    assert_equal 404, other.response.status
    assert_not_equal "hacked", task.reload.title
    foreign_task = foreign_demo.tasks.first
    post tasks_path, params: { task: { title: "Owned", demo_session_id: foreign_demo.id } }
    assert_equal @demo.id, Task.order(:id).last.demo_session_id
    assert Task.exists?(foreign_task.id)
  end

  test "reset restores own samples and leaves another visitor unchanged" do
    other = open_session
    other.get root_path
    foreign = DemoSession.order(:id).last
    foreign_ids = foreign.tasks.ids
    @demo.tasks.destroy_all
    post reset_demo_path
    assert_redirected_to root_path
    assert_equal 7, @demo.tasks.count
    assert_equal foreign_ids, foreign.tasks.ids
  end

  test "expired session gets a new workspace and loses old access" do
    task = @demo.tasks.first
    @demo.update!(expires_at: 1.second.ago)
    get root_path
    assert_response :success
    assert_equal 2, DemoSession.count
    get task_path(task)
    assert_response :not_found
  end

  test "empty states and zero completion render safely" do
    @demo.tasks.destroy_all
    get root_path
    assert_select ".empty-state", 3
    assert_select ".completion strong", text: /0/
  end

  test "health check does not create demo data" do
    assert_no_difference "DemoSession.count" do
      get rails_health_check_path
    end
    assert_response :success
  end
end
