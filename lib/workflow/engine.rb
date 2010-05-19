require 'workflow'
require 'workflow/errors'
require 'workflow/callbacks'
require 'rails'

module Workflow
  # This is the Rails Engine that powers it all.
  # 
  # In the initializer "workflow.default" it sends the :include signal to ActiveRecord to include Base.
  class Engine < Rails::Engine
    # root is namespaced to constellation to work with the include_constellation helper
    config.constellation = ActiveSupport::OrderedOptions.new unless config.respond_to? :constellation
    config.constellation.workflow = ActiveSupport::OrderedOptions.new
    config.constellation.workflow.root = __FILE__.gsub('/lib/workflow/engine.rb', '')
    
    # Configuration options are just namespaced to workflow
    config.workflow = ActiveSupport::OrderedOptions.new
    
    initializer "workflow.default" do |app|
      ActiveRecord::Base.send :include, Workflow::Base
    end
  end
end
