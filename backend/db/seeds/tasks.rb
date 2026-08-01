puts "Creating tasks..."

TASKS_PER_USER = 21
statuses = Task.statuses.keys

User.find_each do |user|
  TASKS_PER_USER.times do |i|
    n = i + 1
    Task.create!(
      user: user,
      title: "#{user.name}のタスク#{n}",
      description: (n.even? ? "#{user.name}のタスク#{n}の説明" : nil),
      status: statuses[i % statuses.size],
      due_date: (Date.today + (n - 10))
    )
  end
end