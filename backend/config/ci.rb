# Run using bin/ci

CI.run do
  step "Setup", "bin/setup --skip-server"

  step "Style: Ruby", "bin/rubocop"

  step "Security: Gem audit", "bin/bundler-audit"
  step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"

  step "Tests: RSpec", "bin/rspec"
  step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"
  step "Cleanup: Test DB", "env RAILS_ENV=test bin/rails db:truncate_all"
end
