module Workflow
  module Base
    def self.included(recipient)
      recipient.extend ClassMethods
      recipient.class_eval { include InstanceMethods }
    end
    
    module ClassMethods
      def on_workflow(name)
        name_symbol = name.underscore.gsub(' ', '_').intern
        self.class_eval <<-RUBY
          has_many :process_instances, :class_name => "Workflow::ProcessInstance", :as => :instance
          
          def start_#{name_symbol}
            @#{name_symbol}_process ||= Workflow::Process.find_by_name #{name.inspect}
            @#{name_symbol}_process_instance ||= Workflow::ProcessInstance.new :process => @#{name_symbol}_process, :instance => self
            @#{name_symbol}_process_instance.nodes << @#{name_symbol}_process.start_node
            @#{name_symbol}_process_instance.save!
          end
          
          def #{name_symbol}
            @#{name_symbol}_process_instance ||= process_instances.process_named(#{name.inspect}).first
          end
        RUBY
      end
    end
    
    module InstanceMethods
      def start_workflow(name)
        
      end
    end
  end
end