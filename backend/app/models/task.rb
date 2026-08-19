class Task < ApplicationRecord
  SORTABLE_COLUMNS = %w[created_at due_date].freeze
  ORDERS           = %w[asc desc].freeze

  belongs_to :user

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }, validate: true

  validates :title, presence: true

  scope :assigned_to, ->(user) { where(user: user) }

  scope :with_status, ->(status) {
    where(status: statuses.fetch(status))
  }

  # column は Arel.sql でSQLに直接展開するため、インジェクションを防ぐ検証が必要
  scope :sorted_by, ->(column, direction) {
    raise ArgumentError, "Invalid column: #{column}" unless SORTABLE_COLUMNS.include?(column.to_s)

    order(Arel.sql("#{column} IS NULL"))
      .order(column.to_sym => direction.to_sym, id: direction.to_sym)
  }
end
