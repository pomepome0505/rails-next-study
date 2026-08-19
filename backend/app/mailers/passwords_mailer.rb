class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    @reset_url = "#{ENV.fetch('FRONTEND_ORIGIN')}/passwords/#{user.password_reset_token}"
    mail subject: "パスワードの再設定", to: user.email
  end
end
