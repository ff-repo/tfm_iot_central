FROM ruby:3.3.5

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  yarn \
  postgresql-client

# Set working directory
WORKDIR /app

# Install Bundler
RUN gem install bundler

RUN ls -la

RUN pwd

# Install gems
RUN bundle install

# Expose the Rails server port
EXPOSE 3000

# Entrypoint script
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Default command to run the Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
