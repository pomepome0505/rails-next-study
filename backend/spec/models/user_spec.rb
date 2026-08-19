require "rails_helper"

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "email が空の場合" do
      it "無効である" do
        user = build(:user, email: "")

        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end
    end

    context "email が既存ユーザーと重複する場合" do
      it "無効である" do
        create(:user, email: "duplicate@example.com")
        user = build(:user, email: "duplicate@example.com")

        expect(user).to be_invalid
        expect(user.errors[:email]).to be_present
      end
    end

    context "email が大文字小文字違いで重複する場合" do
      it "無効である" do
        create(:user, email: "dup@example.com")
        user = build(:user, email: "DUP@EXAMPLE.COM")

        expect(user).to be_invalid
      end
    end

    context "password が空の場合" do
      it "無効である" do
        expect(build(:user, password: nil)).to be_invalid
      end
    end
  end

  describe ".authenticate_by" do
    let!(:user) { create(:user, email: "auth@example.com", password: "password123") }

    context "email とパスワードが一致する場合" do
      it "該当ユーザーを返す" do
        found = described_class.authenticate_by(email: "auth@example.com", password: "password123")

        expect(found).to eq(user)
      end
    end

    context "emailの大文字小文字が異なる場合" do
      it "該当ユーザーを返す" do
        found = described_class.authenticate_by(email: "AUTH@EXAMPLE.COM", password: "password123")

        expect(found).to eq(user)
      end
    end

    context "パスワードが誤っている場合" do
      it "nil を返す" do
        found = described_class.authenticate_by(email: "auth@example.com", password: "wrong")

        expect(found).to be_nil
      end
    end

    context "email が存在しない場合" do
      it "nil を返す" do
        found = described_class.authenticate_by(email: "notexist@example.com", password: "password123")

        expect(found).to be_nil
      end
    end
  end

  describe "#password_reset_token" do
    let(:user) { create(:user, password: "password123") }
    # 仕様: トークンの有効期限は30分
    let(:beyond_token_expiry) { 31.minutes }

    context "発行直後の場合" do
      it "トークンからユーザーを特定できる" do
        token = user.password_reset_token

        expect(described_class.find_by_password_reset_token!(token)).to eq(user)
      end
    end

    context "有効期限を過ぎた場合" do
      it "トークンからユーザーを特定できない" do
        token = user.password_reset_token

        travel_to beyond_token_expiry.from_now do
          expect { described_class.find_by_password_reset_token!(token) }
            .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
        end
      end
    end

    context "パスワードを変更した場合" do
      it "変更前のトークンからユーザーを特定できない" do
        token = user.password_reset_token
        user.update!(password: "newpassword456")

        expect { described_class.find_by_password_reset_token!(token) }
          .to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)
      end
    end
  end

  describe "#destroy" do
    context "セッションが存在する場合" do
      it "セッションも削除される" do
        user = create(:user)
        create(:session, user: user)

        expect { user.destroy }.to change(Session, :count).by(-1)
      end
    end

    context "タスクが存在する場合" do
      it "タスクも削除される" do
        user = create(:user)
        create(:task, user: user)

        expect { user.destroy }.to change(Task, :count).by(-1)
      end
    end
  end
end
