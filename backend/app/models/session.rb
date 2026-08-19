class Session < ApplicationRecord
  belongs_to :user

  INACTIVITY_TIMEOUT = 30.days   # 最終アクセスからの期限（スライディング）
  ABSOLUTE_TIMEOUT   = 90.days   # 作成からの上限
  TOUCH_INTERVAL     = 1.hour    # updated_at を更新する最小間隔
  private_constant :INACTIVITY_TIMEOUT, :ABSOLUTE_TIMEOUT, :TOUCH_INTERVAL

  scope :active, -> {
    where(updated_at: INACTIVITY_TIMEOUT.ago..)
      .where(created_at: ABSOLUTE_TIMEOUT.ago..)
  }

  # 不要になったセッションデータの削除に使用する
  scope :expired, -> {
    where(updated_at: ...INACTIVITY_TIMEOUT.ago)
      .or(where(created_at: ...ABSOLUTE_TIMEOUT.ago))
  }

  def touch_if_stale
    touch if updated_at < TOUCH_INTERVAL.ago
  end
end
