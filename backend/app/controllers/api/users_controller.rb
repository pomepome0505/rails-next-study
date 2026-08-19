module Api
  class UsersController < ApplicationController
    def show
      render json: {
        id: Current.user.id,
        name: Current.user.name,
        email: Current.user.email
      }
    end
  end
end
