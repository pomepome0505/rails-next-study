# spec/support/factory_bot.rb（または rails_helper.rb 内）
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
