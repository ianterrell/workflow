require 'workflow'
require 'workflow/errors'
require 'workflow/callbacks'
require 'rails'

module Workflow
  class Engine < Rails::Engine
    config.workflow = ActiveSupport::OrderedOptions.new
    
    initializer "workflow.default" do |app|
      ActiveRecord::Base.send :include, Workflow::Base
    end
  end
end
