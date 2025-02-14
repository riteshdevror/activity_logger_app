#!/usr/bin/env bash
# exit on error
set -o errexit

# Build commands for back end
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rails assets:precompile
