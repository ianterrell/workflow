require 'workflow'
require 'workflow/errors'
require 'workflow/callbacks'
require 'rails'

module Workflow
  # This is the Rails Engine that powers it all.
  # 
  # In the initializer "workflow.default" it sends the :include signal to ActiveRecord to include Base.
  class Engine < Rails::Engine
    config.workflow = ActiveSupport::OrderedOptions.new
    
    initializer "workflow.default" do |app|
      ActiveRecord::Base.send :include, Workflow::Base
    end
  end
end
