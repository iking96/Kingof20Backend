FROM ruby:2.6.3

# Update apt and install psql client
RUN apt-get update \
  && apt-get install -y postgresql-client

# Change to the application's directory
WORKDIR /application

# Copy over gemfile
# Note: We are copying over the Gemfile
# alone so we don't re-bundle when application
# code is updated
COPY Gemfile* ./

# Update bundler and install gems
RUN gem install bundler:2.1.2 \
  && gem install rails \
  && bundle config set deployment 'true' \
  && bundle config set without 'development test' \
  && bundle update
  && bundle install

# Copy application code
COPY . .

# Set rails to production
ENV RAILS_ENV production

# Start server
CMD ["rails", "server", "-b", "0.0.0.0"]
