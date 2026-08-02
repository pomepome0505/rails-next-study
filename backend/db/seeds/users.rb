puts "Creating users..."

[
  { name: "Alice", email: "alice@example.com" },
  { name: "Bob",   email: "bob@example.com" },
  { name: "Carol", email: "carol@example.com" }
].each { |attrs| User.create!(attrs) }
