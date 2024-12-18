source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.5'
gem 'pry'
gem 'pry-rails'
gem 'pry-byebug'
gem 'rubocop', require: false

# Webpack and React
gem 'webpacker'
gem 'react-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', github: 'rails/rails', branch: "main"

# Use postgres as the database for Active Record
# gem 'sqlite3'
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 3.12'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Authentication with Doorkeeper+Devise
gem 'devise'
gem 'doorkeeper'
gem 'dotenv-rails', groups: [:development, :test, :production]
# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
gem 'capistrano',                 '3.11.2'
gem 'capistrano-rails',           '1.4.0'
gem 'capistrano-rvm'
gem 'capistrano-passenger'
gem 'ed25519', '>= 1.2', '< 2.0'
gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Include testing framework - https://github.com/rspec/rspec-rails
  gem 'rspec-rails', '~> 7.0'
end

group :development do
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1.0'
end

# Gemfile
group :test do
  gem 'factory_bot_rails', '~> 4.0' # Fixtures replacement with a more straightforward syntax
  gem 'shoulda-matchers', '~> 3.1' # Provides RSpec with additional matchers
  gem 'faker' # A library for generating fake data
  gem 'database_cleaner' # Cleans the test database to ensure a clean state in each test suite
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'rubocop-rails', require: false
