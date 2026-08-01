class ApplicationController < ActionController::API
    include ErrorResponse
    include Paginatable::Mixin
end
