module Api
  class PasswordResetsController < ApplicationController
    allow_unauthenticated_access
    before_action :set_user_by_token, only: :update
    rate_limit to: 10, within: 3.minutes, only: :create,
               with: -> { render_error(status: :too_many_requests, message: "Try again later.") }

    def create
      if user = User.find_by(email: params[:email])
        PasswordsMailer.reset(user).deliver_later
      end

      head :accepted
    end

    def update
      if @user.update(params.permit(:password, :password_confirmation))
        @user.sessions.destroy_all
        head :no_content
      else
        render_validation_errors(@user)
      end
    end

    private

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
      render_unauthorized("Password reset link is invalid or has expired")
    end
  end
end
