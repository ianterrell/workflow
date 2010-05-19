source "http://gemcutter.org"

gem "rails", "3.0.0.beta3"
gem "sqlite3-ruby", :require => "sqlite3"

if RUBY_VERSION < '1.9'
  gem "ruby-debug", ">= 0.10.3"
end

gem "factory_girl", :git => "http://github.com/thoughtbot/factory_girl.git", :branch => "rails3"
gem "shoulda", :git => "http://github.com/constellationsoft/shoulda.git", :branch => "rails3"

gem "rspec-rails", ">= 2.0.0.beta"

# Nothing really functional changed on this branch, just deprecation warnings
gem "delayed_job", :git => "http://github.com/constellationsoft/delayed_job.git"

gem "constellation-base", :require => "constellation/base"