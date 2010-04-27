# encoding: UTF-8
require 'rake'
require 'rake/rdoctask'
require 'rake/gempackagetask'

require 'rspec/core'
require 'rspec/core/rake_task'

Rspec::Core::RakeTask.new(:spec)

task :default => :spec

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Workflow'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

spec = Gem::Specification.new do |gem|
  gem.name = "constellation-workflow"
  gem.summary = "A module for managing long running business processes."
  gem.description = "A module for managing long running business processes."
  gem.email = "ian@constellationsoft.com;jeff@constellationsoft.com"
  gem.homepage = "http://github.com/constellationsoft/workflow"
  gem.authors = ["Ian Terrell", "Jeff Bozek"]
  gem.files = Dir["{lib}/**/*.rb", "{app}/**/*", "{config}/**/*"]
  gem.version = "0.0.1"
  gem.post_install_message = <<-EOM
#{"*"*50}

  Thank you for installing ConstellationSoft's Workflow module.

  This is not free software!

  Please see the full license at http://github.com/constellationsoft/workflow/blob/master/LICENSE

#{"*"*50}
EOM
end

Rake::GemPackageTask.new(spec) do |pkg|
end

desc "Install the gem #{spec.name}-#{spec.version}.gem"
task :install do
  system("gem install pkg/#{spec.name}-#{spec.version}.gem --no-ri --no-rdoc")
end
