class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Authentication
    include ErrorResponse
    include Paginatable::Mixin
end
