puts "Cleaning up..."
Task.destroy_all
User.destroy_all

require_relative "seeds/users"
require_relative "seeds/tasks"

puts "Done! users=#{User.count}, tasks=#{Task.count}"
