module Paginatable
  module Mixin
    extend ActiveSupport::Concern

    private

    def paginator
      @paginator ||= Paginator.new(page: params[:page], per_page: params[:per_page])
    end
  end

  Result = Struct.new(:records, :meta, :error_message, keyword_init: true) do
    def success?
      error_message.nil?
    end
  end

  class Paginator
    DEFAULT_PER_PAGE = 10
    MAX_PER_PAGE = 100

    def initialize(page:, per_page:)
      @page = page.presence || 1
      @per_page = per_page.presence || DEFAULT_PER_PAGE
    end

    def paginate(collection)
      if (message = error_message)
        return Result.new(records: nil, meta: nil, error_message: message)
      end

      records = collection.page(@page).per(@per_page)

      Result.new(records: records, meta: meta(records), error_message: nil)
    end

    private

    def error_message
      return "Invalid page" unless positive_integer?(@page)
      return "Invalid per_page" unless positive_integer?(@per_page)
      return "per_page is too large" if @per_page.to_i > MAX_PER_PAGE

      nil
    end

    def meta(records)
      {
        current_page: records.current_page,
        per_page: records.limit_value,
        total_pages: records.total_pages,
        total_count: records.total_count,
        next_page: records.next_page,
        prev_page: records.prev_page
      }
    end

    def positive_integer?(value)
      value.to_s.match?(/\A[1-9]\d*\z/)
    end
  end
end
