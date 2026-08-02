# spec/factories/tasks.rb
FactoryBot.define do
  factory :task do
    association :user
    title { "サンプルタスク" }
    status { :todo }
  end
end
