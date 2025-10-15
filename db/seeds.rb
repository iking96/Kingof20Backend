# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Create OAuth application as public client (no secret required)
client_id = ENV['REACT_APP_CLIENT_ID'] || 'L-RLA7_dL8Tze9jBXrCbMhGyHMBIZ-yk12y1c_jYsNQ'

# Find or create the main application
app = Doorkeeper::Application.find_or_create_by(uid: client_id) do |application|
  application.name = 'King of 20 Frontend'
  application.secret = nil  # Public client - no secret
  application.confidential = false  # Explicitly mark as public
  application.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
  application.scopes = ''
end

puts "OAuth Application: #{app.name} (#{app.uid})"

User.first_or_create(
    email: 'ishmael@example.com',
    username: 'iking',
    password: 'password1'
)