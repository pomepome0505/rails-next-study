require "rails_helper"

RSpec.describe Task, type: :model do
  describe "バリデーション" do
    context "titleとstatusとuserがある場合" do
      it "有効である" do
        task = build(:task)

        expect(task).to be_valid
      end
    end

    context "titleがない場合" do
      it "無効である" do
        task = build(:task, title: nil)

        expect(task).to be_invalid
        expect(task.errors.details[:title]).to include(error: :blank)
      end
    end

    context "userがない場合" do
      it "無効である" do
        task = build(:task, user: nil)

        expect(task).to be_invalid
        expect(task.errors.details[:user]).to include(error: :blank)
      end
    end

    context "statusが不正な値の場合" do
      it "無効である" do
        task = build(:task, status: nil)

        expect(task).to be_invalid
        expect(task.errors).to be_of_kind(:status, :inclusion)
      end
    end
  end

  describe ".scope" do
    context "statusを指定した場合" do
      it "指定したstatusのタスクだけを取得する" do
        todo_task = create(:task, status: :todo)
        create(:task, status: :done)

        result = described_class.with_status("todo")

        expect(result).to contain_exactly(todo_task)
      end
    end
  end

  describe ".order_by_due_date" do
    context "ascを指定した場合" do
      it "due_dateの昇順で並び、nilは末尾に置く" do
        no_due_task = create(:task, due_date: nil)
        later_task = create(:task, due_date: Date.new(2026, 7, 30))
        earlier_task = create(:task, due_date: Date.new(2026, 7, 20))

        result = described_class.order_by_due_date("asc")

        expect(result).to eq([ earlier_task, later_task, no_due_task ])
      end
    end

    context "descを指定した場合" do
      it "due_dateの降順で並び、nilは末尾に置く" do
        no_due_task = create(:task, due_date: nil)
        earlier_task = create(:task, due_date: Date.new(2026, 7, 20))
        later_task = create(:task, due_date: Date.new(2026, 7, 30))

        result = described_class.order_by_due_date("desc")

        expect(result).to eq([ later_task, earlier_task, no_due_task ])
      end
    end
  end

  describe ".recent" do
    it "created_atの降順でタスクを取得する" do
      new_task = create(
        :task,
        created_at: Time.zone.local(2026, 7, 2, 10, 0, 0)
      )
      old_task = create(
        :task,
        created_at: Time.zone.local(2026, 7, 1, 10, 0, 0)
      )


      result = described_class.recent

      expect(result).to eq([ new_task, old_task ])
    end
  end
end
