class DemoSession < ApplicationRecord
  LIFETIME = 7.days
  has_many :tasks, dependent: :destroy
  validates :token, presence: true, uniqueness: true
  scope :expired, -> { where("expires_at <= ?", Time.current) }

  def self.start!
    transaction do
      demo = create!(token: SecureRandom.hex(32), expires_at: LIFETIME.from_now)
      demo.seed_tasks!
      demo
    end
  end

  def reset!
    with_lock do
      tasks.destroy_all
      seed_tasks!
    end
  end

  def seed_tasks!
    [
      ["ユーザーインタビューを整理する", "ヒアリング結果から、ユーザーの課題と改善のヒントをまとめる。", "todo", "high", 1],
      ["ダッシュボードのUIを設計する", "サマリーとKanbanの情報設計を検討する。モバイルでの操作性も確認。", "in_progress", "high", 2],
      ["APIのエラーハンドリングを見直す", "入力エラーと権限エラーを整理して、わかりやすいメッセージにする。", "todo", "medium", -1],
      ["リリース前の動作確認", "作成・編集・削除とフィルターの一連の操作を確認する。", "todo", "low", 5],
      ["プロジェクトの環境構築", "Railsとデータベースを準備し、チームの開発手順をまとめる。", "done", "medium", -2],
      ["タスクの状態管理を実装する", "モデルに状態変更を集約し、不正なステータスを拒否する。", "in_progress", "medium", 3],
      ["要件定義をまとめる", "MVPのスコープと優先順位を決める。", "done", "high", -3]
    ].each do |title, description, status, priority, offset|
      tasks.create!(title: title, description: description, status: status, priority: priority, due_date: Date.current + offset)
    end
  end
end
