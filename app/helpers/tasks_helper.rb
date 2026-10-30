module TasksHelper
  def status_label(value)
    Task::STATUSES.fetch(value)
  end

  def priority_label(value)
    Task::PRIORITIES.fetch(value)
  end
end
