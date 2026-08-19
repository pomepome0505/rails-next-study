require "rails_helper"

RSpec.describe Session, type: :model do
  let(:user) { create(:user) }
  let(:within_inactivity_limit) { 29.days.ago }
  let(:beyond_inactivity_limit) { 31.days.ago }
  let(:within_absolute_limit)   { 89.days.ago }
  let(:beyond_absolute_limit)   { 91.days.ago }
  let(:within_touch_interval)   { 30.minutes.ago }
  let(:beyond_touch_interval)   { 2.hours.ago }

  describe ".active" do
    context "どちらの期限にも達していない場合" do
      it "含まれる" do
        session = create(:session, user: user)
        session.update_columns(created_at: within_absolute_limit, updated_at: within_inactivity_limit)

        expect(described_class.active).to include(session)
      end
    end

    context "最終アクセスから30日を超えている場合" do
      it "含まれない" do
        session = create(:session, user: user)
        session.update_columns(created_at: within_absolute_limit, updated_at: beyond_inactivity_limit)

        expect(described_class.active).not_to include(session)
      end
    end

    context "作成から90日を超えている場合" do
      it "最終アクセスが直近でも含まれない" do
        session = create(:session, user: user)
        session.update_columns(created_at: beyond_absolute_limit, updated_at: 1.hour.ago)

        expect(described_class.active).not_to include(session)
      end
    end
  end

  describe ".expired" do
    context "どちらの期限にも達していない場合" do
      it "含まれない" do
        session = create(:session, user: user)
        session.update_columns(created_at: within_absolute_limit, updated_at: within_inactivity_limit)

        expect(described_class.expired).not_to include(session)
      end
    end

    context "最終アクセスから30日を超えている場合" do
      it "含まれる" do
        session = create(:session, user: user)
        session.update_columns(created_at: within_absolute_limit, updated_at: beyond_inactivity_limit)

        expect(described_class.expired).to include(session)
      end
    end

    context "作成から90日を超えている場合" do
      it "最終アクセスが直近でも含まれる" do
        session = create(:session, user: user)
        session.update_columns(created_at: beyond_absolute_limit, updated_at: 1.hour.ago)

        expect(described_class.expired).to include(session)
      end
    end
  end

  describe "#touch_if_stale" do
    context "最終更新から1時間を超えている場合" do
      it "updated_at を更新する" do
        session = create(:session, user: user)
        session.update_columns(updated_at: beyond_touch_interval)

        expect { session.touch_if_stale }.to change { session.reload.updated_at }
      end
    end

    context "最終更新から1時間以内の場合" do
      it "updated_at を更新しない" do
        session = create(:session, user: user)
        session.update_columns(updated_at: within_touch_interval)

        expect { session.touch_if_stale }.not_to change { session.reload.updated_at }
      end
    end
  end
end
