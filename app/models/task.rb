class Task < ApplicationRecord
  STATUSES = { "todo" => "Todo", "in_progress" => "In Progress", "done" => "Done" }.freeze
  PRIORITIES = { "low" => "低", "medium" => "中", "high" => "高" }.freeze
  belongs_to :demo_session
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 5000 }
  validates :status, inclusion: { in: STATUSES.keys }
  validates :priority, inclusion: { in: PRIORITIES.keys }
  validate :valid_due_date
  scope :overdue, -> { where("due_date < ?", Date.current).where.not(status: "done") }
  scope :ordered, -> { order(Arel.sql("CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END"), :due_date, created_at: :desc) }

  def transition_to(value)
    update(status: value)
  end

  def overdue?
    due_date.present? && due_date < Date.current && status != "done"
  end

  private

  def valid_due_date
    raw = due_date_before_type_cast
    return if raw.blank? || raw.is_a?(Date)
    unless raw.is_a?(String) && raw.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.iso8601(raw)
      errors.add(:due_date, "はYYYY-MM-DD形式の有効な日付を入力してください")
    end
  rescue ArgumentError
    errors.add(:due_date, "は有効な日付を入力してください")
  end
end
