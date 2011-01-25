module Workflow
  # This is the Rails Engine that powers it all.
  # 
  # In the initializer "workflow.default" it sends the :include signal to ActiveRecord to include Base.
  class Engine < Rails::Engine
    config.workflow = ActiveSupport::OrderedOptions.new
    config.workflow.root = __FILE__.gsub('/lib/workflow/engine.rb', '')
  
    # Set to something other than :delayed_job to provide your own implementation
    config.workflow.timer_engine = :delayed_job
  
    initializer "workflow.default" do |app|
      ActiveRecord::Base.send :include, ::Workflow::Base
    end
  end
end