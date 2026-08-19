require "rails_helper"

RSpec.describe "パスワードリセットAPI", type: :request do
  def response_json
    JSON.parse(response.body)
  end

  let!(:user) { create(:user, email: "alice@example.com", password: "password123") }

  describe "POST /api/password_resets" do
    context "登録済みのメールアドレスを指定した場合" do
      it "202 Acceptedを返し、リセットメールを送信する" do
        expect {
          post "/api/password_resets", params: { email: "alice@example.com" }, as: :json
        }.to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to have_http_status(:accepted)
        expect(response.body).to be_blank
      end
    end

    context "未登録のメールアドレスを指定した場合" do
      it "202 Acceptedを返すが、メールは送信しない" do
        expect {
          post "/api/password_resets", params: { email: "notexist@example.com" }, as: :json
        }.not_to have_enqueued_mail(PasswordsMailer, :reset)

        expect(response).to have_http_status(:accepted)
        expect(response.body).to be_blank
      end
    end
  end

  describe "PUT /api/password_resets/:token" do
    context "有効なトークンを指定した場合" do
      it "204 No Contentを返し、パスワードを変更して全セッションを破棄する" do
        sign_in_as(user)
        token = user.password_reset_token
        params = { password: "newpassword456", password_confirmation: "newpassword456" }

        expect {
          put "/api/password_resets/#{token}", params: params, as: :json
        }.to change(Session, :count).by(-1)

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_blank
        expect(user.reload.authenticate("newpassword456")).to be_truthy
      end
    end

    context "無効なトークンを指定した場合" do
      it "401 Unauthorizedを返す" do
        params = { password: "newpassword456", password_confirmation: "newpassword456" }

        put "/api/password_resets/invalid_token", params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response_json).to match(
          "message" => "Password reset link is invalid or has expired",
          "errors" => [],
          "request_id" => String
        )
      end
    end

    context "パスワードと確認用パスワードが一致しない場合" do
      it "422 Unprocessable Contentを返し、パスワードを変更しない" do
        token = user.password_reset_token
        params = { password: "newpassword456", password_confirmation: "different" }

        put "/api/password_resets/#{token}", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(response_json).to match(
          "message" => "Validation failed",
          "errors" => contain_exactly(
            { "field" => "password_confirmation", "code" => "confirmation", "message" => String, "full_message" => String }
          ),
          "request_id" => String
        )
        expect(user.reload.authenticate("password123")).to be_truthy
      end
    end
  end
end
