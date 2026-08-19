module AuthenticationHelper
  # 認証済みの状態にする。以降のリクエストに Cookie が引き継がれる
  def sign_in_as(user, password: "password123")
    post "/api/session", params: { email: user.email, password: password }, as: :json
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper, type: :request
end
