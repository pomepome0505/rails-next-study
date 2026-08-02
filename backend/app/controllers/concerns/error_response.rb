module ErrorResponse
    extend ActiveSupport::Concern

    included do
        rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
        rescue_from ActionController::ParameterMissing, with: :render_parameter_missing
    end

    private

    def render_parameter_missing(exception)
        render_bad_request("param is missing: #{exception.param}")
    end

    def render_validation_errors(record)
        render_error(
            status: :unprocessable_content,
            message: "Validation failed",
            errors: record.errors.map do |error|
                {
                    field: error.attribute,
                    code: error.type,
                    message: error.message,
                    full_message: error.full_message
                }
            end
        )
    end

    def render_not_found
        render_error(
            status: :not_found,
            message: "Resource not found"
        )
    end

    def render_bad_request(message = "Bad request")
        render_error(
            status: :bad_request,
            message: message
        )
    end

    def render_unauthorized(message = "Unauthorized")
        render_error(
            status: :unauthorized,
            message: message
        )
    end

    def render_forbidden(message = "Forbidden")
        render_error(
            status: :forbidden,
            message: message
        )
    end

    def render_error(status:, message:, errors: [])
        render json: {
            message: message,
            errors: errors,
            request_id: request.request_id
        }, status: status
    end
end
