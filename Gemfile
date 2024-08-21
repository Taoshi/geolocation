# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.1'

gem 'bootsnap', require: false
gem 'dotenv-rails'
gem 'httparty'
gem 'ipaddress'
gem 'pg'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.8', '>= 7.0.8.4'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'rswag'
gem 'rswag-ui'
gem 'rswag-api'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'rubocop-performance'
  gem 'rubocop'
  gem 'rswag-specs'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot'
  gem 'faker'
  gem 'rspec-rails', '~> 6.1.0'
  gem 'rspec-retry'
  gem 'shoulda-matchers'
  gem 'simplecov'
  gem 'webmock'
end
