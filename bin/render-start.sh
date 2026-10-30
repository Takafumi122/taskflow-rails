#!/usr/bin/env bash
set -o errexit
bundle exec rails db:migrate
bundle exec rails demo:cleanup
exec bundle exec puma -C config/puma.rb
