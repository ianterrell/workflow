# encoding: UTF-8
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Workflow'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb', 'app/**/*.rb')
end

spec = Gem::Specification.new do |gem|
  gem.name = "workflow"
  gem.summary = "A module for managing long running business processes."
  gem.description = "A module for managing long running business processes."
  gem.email = "ian.terrell@gmail.com"
  gem.homepage = "http://github.com/ianterrell/workflow"
  gem.authors = ["Ian Terrell"]
  gem.files = Dir["{lib}/**/*", "{app}/**/*", "{config}/**/*"]
  gem.version = "0.0.1"
end

Rake::GemPackageTask.new(spec) do |pkg|
end

desc "Install the gem #{spec.name}-#{spec.version}.gem"
task :install do
  system("gem install pkg/#{spec.name}-#{spec.version}.gem --no-ri --no-rdoc")
end
