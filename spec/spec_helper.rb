# frozen_string_literal: true

require File.expand_path('../config/environment', __dir__)

require 'rubygems'
require 'simplecov'
require 'rspec/rails'
require 'factory_bot'
require 'shoulda/matchers'
require 'database_cleaner'
require 'faker'
require 'rspec/core'
require 'rspec/expectations'
require 'rspec/mocks'
require 'rake'
require 'rspec/retry'
require 'webmock/rspec'

SimpleCov.start('rails') do
  coverage_dir('public/coverage')
end

WebMock.disable_net_connect!(allow_localhost: true)

ENV['RAILS_ENV'] ||= 'test'
Rails.env = 'test'


FactoryBot.find_definitions
Dir[Rails.root.join('spec/support/**/*.rb')].each { |file| require file }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.raise_errors_for_deprecations!

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.default_formatter = 'doc' if config.files_to_run.one?
  Kernel.srand(config.seed)

  Shoulda::Matchers.configure do |conf|
    conf.integrate do |with|
      with.test_framework(:rspec)
      with.library(:rails)
    end
  end

  config.verbose_retry = false
  config.display_try_failure_messages = true
  config.around :each do |ex|
    ex.run_with_retry retry: 7
  end
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation) # Clean the database before the suite starts
  end

  # config.before(:each) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

  config.after(:suite) do
    DatabaseCleaner.clean_with(:truncation) # Ensure the database is clean after the suite ends
  end
end
