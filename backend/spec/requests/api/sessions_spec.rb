require "rails_helper"

RSpec.describe "セッションAPI", type: :request do
  def response_json
    JSON.parse(response.body)
  end

  let!(:user) do
    create(:user, name: "Alice", email: "alice@example.com", password: "password123")
  end

  describe "POST /api/session" do
    context "正しいメールアドレスとパスワードの場合" do
      it "ログインでき、セッションとCookieが作成される" do
        params = { email: "alice@example.com", password: "password123" }

        expect {
          post "/api/session", params: params, as: :json
        }.to change(Session, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response_json).to match(
          "id" => user.id,
          "name" => "Alice",
          "email" => "alice@example.com"
        )
        expect(response.headers["Set-Cookie"]).to match(
          /\Asession_id=[^;]+; path=\/; expires=[^;]+; httponly; samesite=lax\z/i
        )
      end
    end

    context "パスワードが誤っている場合" do
      it "401 Unauthorizedを返し、セッションもCookieも作成しない" do
        params = { email: "alice@example.com", password: "wrong_password" }

        expect {
          post "/api/session", params: params, as: :json
        }.not_to change(Session, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response_json).to match(
          "message" => "Invalid email or password",
          "errors" => [],
          "request_id" => String
        )
        expect(response.headers["Set-Cookie"]).to be_nil
      end
    end

    context "メールアドレスが存在しない場合" do
      it "401 Unauthorizedを返し、セッションもCookieも作成しない" do
        params = { email: "notexist@example.com", password: "password123" }

        expect {
          post "/api/session", params: params, as: :json
        }.not_to change(Session, :count)

        expect(response).to have_http_status(:unauthorized)
        expect(response_json).to match(
          "message" => "Invalid email or password",
          "errors" => [],
          "request_id" => String
        )
        expect(response.headers["Set-Cookie"]).to be_nil
      end
    end
  end

  describe "DELETE /api/session" do
    context "ログイン済みの場合" do
      it "セッションを削除し、以降は認証が必要なエンドポイントにアクセスできない" do
        sign_in_as(user)

        expect {
          delete "/api/session"
        }.to change(Session, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_blank

        get "/api/me"
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "未ログインの場合" do
      it "401 Unauthorizedを返す" do
        delete "/api/session"

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
