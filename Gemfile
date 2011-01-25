source "http://gemcutter.org"

gem "rails", "3.0.3"
gem "sqlite3-ruby", :require => "sqlite3"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

group :test do
  gem "factory_girl"
  gem "shoulda"
  gem "rspec-rails"
end

gem "delayed_job"