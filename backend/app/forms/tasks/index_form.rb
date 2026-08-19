module Tasks
  class IndexForm
    include ActiveModel::Model
    include ActiveModel::Attributes

    DEFAULT_SORT_BY = "created_at"
    DEFAULT_ORDER   = "desc"

    attribute :status,  :string
    attribute :sort_by, :string, default: DEFAULT_SORT_BY
    attribute :order,   :string, default: DEFAULT_ORDER

    validates :status,  inclusion: { in: ->(_) { Task.statuses.keys } }, allow_blank: true
    validates :sort_by, inclusion: { in: Task::SORTABLE_COLUMNS }
    validates :order,   inclusion: { in: Task::ORDERS }
  end
end
