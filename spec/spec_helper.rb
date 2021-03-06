# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Bundler.require :test

require "rails/test_help"
require "rspec/rails"

require "#{File.dirname(__FILE__)}/factories.rb"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

Rspec.configure do |config|
  # Remove this line if you don't want Rspec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include Rspec::Matchers
  require 'shoulda/active_record/matchers'
  require 'shoulda/action_controller/matchers'
  # require 'active_support/test_case'

  config.include Shoulda::ActiveRecord::Matchers
  config.include Shoulda::ActionController::Matchers

  # == Mock Framework
  config.mock_with :rspec
end
