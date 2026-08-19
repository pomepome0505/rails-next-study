puts "Creating users..."

[
  { name: "Alice", email: "alice@example.com" },
  { name: "Bob",   email: "bob@example.com" },
  { name: "Carol", email: "carol@example.com" }
].each do |attrs|
  User.create!(
    name: attrs[:name],
    email: attrs[:email],
    password: "password123"
  )
end
