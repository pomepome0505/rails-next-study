class Api::HealthController < ApplicationController
  def show
    render json: {
      status: "ok",
      message: "Rails API is running"
    }
  end
end