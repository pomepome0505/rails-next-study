require "rails_helper"

RSpec.describe "ユーザーAPI", type: :request do
  def response_json
    JSON.parse(response.body)
  end

  let(:user) { create(:user, name: "Alice", email: "alice@example.com") }

  describe "GET /api/me" do
    context "ログイン済みの場合" do
      it "ログイン中のユーザー情報を返す" do
        sign_in_as(user)

        get "/api/me"

        expect(response).to have_http_status(:ok)
        expect(response_json).to match(
          "id" => user.id,
          "name" => "Alice",
          "email" => "alice@example.com"
        )
      end
    end

    context "未ログインの場合" do
      it "401 Unauthorizedを返す" do
        get "/api/me"

        expect(response).to have_http_status(:unauthorized)
        expect(response_json).to match(
          "message" => "認証が必要です",
          "errors" => [],
          "request_id" => String
        )
      end
    end
  end
end
