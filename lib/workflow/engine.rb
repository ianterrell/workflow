require 'workflow'
require 'workflow/errors'
require 'rails'

module Workflow
  class Engine < Rails::Engine
    initializer "workflow.default" do |app|
      ActiveRecord::Base.send :include, Workflow::Base
    end
  end
end
