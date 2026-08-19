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

  describe ".assigned_to" do
    it "指定したユーザーのタスクだけを取得する" do
      owner = create(:user)
      own_task = create(:task, user: owner)
      create(:task, user: create(:user))

      expect(described_class.assigned_to(owner)).to contain_exactly(own_task)
    end
  end

  describe ".with_status" do
    context "statusを指定した場合" do
      it "指定したstatusのタスクだけを取得する" do
        todo_task = create(:task, status: :todo)
        create(:task, status: :done)

        result = described_class.with_status("todo")

        expect(result).to contain_exactly(todo_task)
      end
    end
  end

  describe ".sorted_by" do
    context "due_dateを昇順で指定した場合" do
      it "due_dateの昇順で並び、nilは末尾に置く" do
        user = create(:user)
        no_due_date = create(:task, user: user, due_date: nil)
        later       = create(:task, user: user, due_date: Date.new(2026, 7, 30))
        earlier     = create(:task, user: user, due_date: Date.new(2026, 7, 20))

        result = described_class.sorted_by("due_date", "asc")

        expect(result.map(&:id)).to eq([ earlier.id, later.id, no_due_date.id ])
      end
    end

    context "due_dateを降順で指定した場合" do
      it "due_dateの降順で並び、nilは末尾に置く" do
        user = create(:user)
        no_due_date = create(:task, user: user, due_date: nil)
        earlier     = create(:task, user: user, due_date: Date.new(2026, 7, 20))
        later       = create(:task, user: user, due_date: Date.new(2026, 7, 30))

        result = described_class.sorted_by("due_date", "desc")

        expect(result.map(&:id)).to eq([ later.id, earlier.id, no_due_date.id ])
      end
    end

    context "created_atを降順で指定した場合" do
      it "created_atの降順で並ぶ" do
        user   = create(:user)
        older  = create(:task, user: user, created_at: 2.days.ago)
        newer  = create(:task, user: user, created_at: 1.day.ago)

        result = described_class.sorted_by("created_at", "desc")

        expect(result.map(&:id)).to eq([ newer.id, older.id ])
      end
    end

    context "同じ値のレコードが複数ある場合" do
      it "idで順序が安定する" do
        user  = create(:user)
        due   = Date.new(2026, 7, 20)
        first  = create(:task, user: user, due_date: due)
        second = create(:task, user: user, due_date: due)
        third  = create(:task, user: user, due_date: due)

        result = described_class.sorted_by("due_date", "asc")

        expect(result.map(&:id)).to eq([ first.id, second.id, third.id ])
      end
    end

    context "許可されていないカラムを指定した場合" do
      it "ArgumentErrorが発生する" do
        expect { described_class.sorted_by("title", "asc") }
          .to raise_error(ArgumentError)
      end
    end
  end
end
