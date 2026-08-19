require "rails_helper"

RSpec.describe Tasks::IndexForm do
  describe "#valid?" do
    context "パラメータを何も指定しない場合" do
      it "有効であり、既定値が適用される" do
        form = described_class.new

        expect(form).to be_valid
        expect(form.status).to be_nil
        expect(form.sort_by).to eq("created_at")
        expect(form.order).to eq("desc")
      end
    end

    describe "status" do
      Task.statuses.each_key do |status|
        context "許可された値（#{status}）を指定した場合" do
          it "有効である" do
            form = described_class.new(status: status)

            expect(form).to be_valid
          end
        end
      end

      context "許可されていない値を指定した場合" do
        it "無効であり、inclusionエラーになる" do
          form = described_class.new(status: "unknown")

          expect(form).to be_invalid
          expect(form.errors.details[:status]).to include(a_hash_including(error: :inclusion))
        end
      end

      [ nil, "" ].each do |blank|
        context "空の値（#{blank.inspect}）を指定した場合" do
          it "有効である" do
            form = described_class.new(status: blank)

            expect(form).to be_valid
          end
        end
      end
    end

    describe "sort_by" do
      Task::SORTABLE_COLUMNS.each do |column|
        context "許可された値（#{column}）を指定した場合" do
          it "有効であり、指定した値が保持される" do
            form = described_class.new(sort_by: column)

            expect(form).to be_valid
            expect(form.sort_by).to eq(column)
          end
        end
      end

      context "許可されていない値を指定した場合" do
        it "無効であり、inclusionエラーになる" do
          form = described_class.new(sort_by: "title")

          expect(form).to be_invalid
          expect(form.errors.details[:sort_by]).to include(a_hash_including(error: :inclusion))
        end
      end

      context "空文字を指定した場合" do
        it "無効である" do
          form = described_class.new(sort_by: "")

          expect(form).to be_invalid
        end
      end
    end

    describe "order" do
      Task::ORDERS.each do |order|
        context "許可された値（#{order}）を指定した場合" do
          it "有効であり、指定した値が保持される" do
            form = described_class.new(order: order)

            expect(form).to be_valid
            expect(form.order).to eq(order)
          end
        end
      end

      context "許可されていない値を指定した場合" do
        it "無効であり、inclusionエラーになる" do
          form = described_class.new(order: "random")

          expect(form).to be_invalid
          expect(form.errors.details[:order]).to include(a_hash_including(error: :inclusion))
        end
      end

      context "空文字を指定した場合" do
        it "無効である" do
          form = described_class.new(order: "")

          expect(form).to be_invalid
        end
      end
    end
  end
end
