class User < ApplicationRecord
  PASSWORD_RESET_EXPIRY = 30.minutes

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :tasks, dependent: :destroy

  normalizes :email, with: ->(e) { e.strip.downcase }
  validates :email, presence: true, uniqueness: true

  generates_token_for :password_reset, expires_in: PASSWORD_RESET_EXPIRY do
    password_salt&.last(10)
  end
end
