require 'constellation/workflow'
require 'workflow'
require 'workflow/errors'
require 'workflow/callbacks'
require 'rails'
require 'active_record'

module Constellation
  module Workflow
    # This is the Rails Engine that powers it all.
    # 
    # In the initializer "constellation.workflow.default" it sends the :include signal to ActiveRecord to include Base.
    class Engine < Rails::Engine
      config.constellation = ActiveSupport::OrderedOptions.new unless config.respond_to? :constellation
      config.constellation.workflow = ActiveSupport::OrderedOptions.new
      config.constellation.workflow.root = __FILE__.gsub('/lib/constellation/workflow/engine.rb', '')
    
      # Set to something other than :delayed_job to provide your own implementation
      config.constellation.workflow.timer_engine = :delayed_job
    
      initializer "constellation.workflow.default" do |app|
        ActiveRecord::Base.send :include, ::Workflow::Base
      end
    end
  end
end