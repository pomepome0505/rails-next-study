require "rails_helper"

RSpec.describe Paginatable::Paginator do
  describe "#paginate" do
    def paginate(page: nil, per_page: nil)
      described_class.new(page: page, per_page: per_page).paginate(Task.none)
    end

    describe "pageの検証" do
      context "指定しない場合" do
        [nil, ""].each do |blank|
          it "#{blank.inspect} は既定値の1として扱う" do
            result = paginate(page: blank)

            expect(result).to be_success
            expect(result.meta).to include(current_page: 1)
          end
        end
      end

      context "正の整数以外を指定した場合" do
        ["0", "-1", "abc", "1.5"].each do |invalid_page|
          it "#{invalid_page.inspect} を不正な値として扱う" do
            result = paginate(page: invalid_page)

            expect(result).not_to be_success
            expect(result.error_message).to eq("Invalid page")
          end
        end
      end
    end

    describe "per_pageの検証" do
      context "指定しない場合" do
        [nil, ""].each do |blank|
          it "#{blank.inspect} は既定値の10として扱う" do
            result = paginate(per_page: blank)

            expect(result).to be_success
            expect(result.meta).to include(per_page: 10)
          end
        end
      end

      context "正の整数以外を指定した場合" do
        ["0", "-1", "abc", "1.5"].each do |invalid_per_page|
          it "#{invalid_per_page.inspect} を不正な値として扱う" do
            result = paginate(per_page: invalid_per_page)

            expect(result).not_to be_success
            expect(result.error_message).to eq("Invalid per_page")
          end
        end
      end

      context "上限の境界値を指定した場合" do
        it "per_pageが100の場合は許容する" do
        
          result = paginate(per_page: "100")
          expect(result).to be_success
          expect(result.meta).to include(per_page: 100)
        end

        it "per_pageが101の場合は上限超過として扱う" do
          result = paginate(per_page: "101")

          expect(result).not_to be_success
          expect(result.error_message).to eq("per_page is too large")
        end
      end
    end
  end
end