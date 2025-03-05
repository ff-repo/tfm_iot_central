#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Run database migrations if needed
bundle exec rails db:migrate 2>/dev/null || bundle exec rails db:setup

# Execute the container’s main process
exec "$@"