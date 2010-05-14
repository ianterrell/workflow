module Workflow
  # This module extends the functionality of ActiveRecord to support Workflow.
  module Base
    def self.included(recipient) #:nodoc:
      recipient.extend ClassMethods
      recipient.class_eval { include InstanceMethods }
    end
    
    # This module provides the class level methods that can be used within ActiveRecord model declarations.
    module ClassMethods
      
      # This method declares that a model is on a workflow named 'name'.
      # 
      # It does the following:
      # 1. It associates this model with process_instances of class ProcessInstance with a polymorphic has_many
      # 2. It defines the method start_workflow_name on the model, which, when called, kicks off the workflow process
      #    by moving the instance into the start state.
      # 3. It defines the method workflow_name on the model, which returns the ProcessInstance associated with this model and process.
      def on_workflow(name)
        name_symbol = name.underscore.gsub(' ', '_').intern
        self.class_eval <<-RUBY
          has_many :process_instances, :class_name => "Workflow::ProcessInstance", :as => :instance
          
          def start_#{name_symbol}
            @#{name_symbol}_process ||= Workflow::Process.find_by_name #{name.inspect}
            @#{name_symbol}_process_instance ||= Workflow::ProcessInstance.new :process => @#{name_symbol}_process, :instance => self
            @#{name_symbol}_process_instance.nodes << @#{name_symbol}_process.start_node
            @#{name_symbol}_process_instance.save!
            @#{name_symbol}_process.start_node.schedule_actions @#{name_symbol}_process_instance
            @#{name_symbol}_process.start_node.execute_enter_callbacks @#{name_symbol}_process_instance
          end
          
          def #{name_symbol}
            @#{name_symbol}_process_instance ||= process_instances.process_named(#{name.inspect}).first
          end
        RUBY
      end
    end
    
    module InstanceMethods #:nodoc:

    end
  end
end