module Api
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: :create
    rate_limit to: 10, within: 3.minutes, only: :create,
               with: -> { render_error(status: :too_many_requests, message: "Try again later.") }

    def create
      user = User.authenticate_by(params.permit(:email, :password))

      if user
        start_new_session_for(user)
        render json: { id: user.id, name: user.name, email: user.email }, status: :created
      else
        render_unauthorized("Invalid email or password")
      end
    end

    def destroy
      terminate_session
      head :no_content
    end
  end
end
