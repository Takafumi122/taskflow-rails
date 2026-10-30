require "test_helper"

class DemoSessionTest < ActiveSupport::TestCase
  test "creates random independent workspaces with samples" do
    first = DemoSession.start!
    second = DemoSession.start!
    assert_match(/\A[0-9a-f]{64}\z/, first.token)
    assert_not_equal first.token, second.token
    assert_equal 7, first.tasks.count
    assert_equal 7, second.tasks.count
  end

  test "reset only affects its own tasks" do
    first = DemoSession.start!
    second = DemoSession.start!
    second_ids = second.tasks.ids
    first.tasks.destroy_all
    first.reset!
    assert_equal 7, first.tasks.count
    assert_equal second_ids, second.tasks.ids
  end

  test "expiration cleanup destroys owned tasks only" do
    old = DemoSession.start!
    current = DemoSession.start!
    old.update!(expires_at: 1.second.ago)
    DemoSession.expired.find_each(&:destroy!)
    assert_not DemoSession.exists?(old.id)
    assert_equal 0, Task.where(demo_session_id: old.id).count
    assert_equal 7, current.tasks.count
  end
end
