class Task < ApplicationRecord
    belongs_to :user
    enum :status, {
        todo: "todo",
        in_progress: "in_progress",
        done: "done"
    }, validate: true

    validates :title, presence: true

    scope :with_status, ->(status) {
        where(status: statuses.fetch(status))
    }

    scope :order_by_due_date, ->(direction) {
        order(Arel.sql("due_date IS NULL"))
        .order(due_date: direction.to_sym)
    }

    scope :recent, -> {
        order(created_at: :desc)
    }
end
