module Workflow
  # This module encapsulates the behavior of callbacks, used internally for Node's enter_callbacks and exit_callbacks,
  # and Transition's unnamed callbacks.
  #
  # Callbacks are methods that are sent to the instance on the workflow when they are executed.  If the instance does
  # not respond to a particular callback, execution continues but a warning is logged.
  module Callbacks
    def self.included(recipient) #:nodoc:
      recipient.extend ClassMethods
      recipient.class_eval { include InstanceMethods }
    end
    
    module ClassMethods #:nodoc:all
      def has_callbacks(*names)
        names = [''] if names.empty?
        names.map!{|name| :"#{name}#{"_" unless name.to_s.empty?}callbacks"}
        names.each do |callback|
          self.class_eval <<-RUBY
            serialize #{callback.inspect}
            validate #{callback.inspect}_are_valid

            def execute_#{callback}(process_instance)
              execute_callback_type_on_instance #{callback.inspect}, process_instance.instance
            end
          
            protected
            def #{callback}_are_valid
              validate_callbacks #{callback.inspect}
            end
          RUBY
        end
      end
    end
    
    module InstanceMethods #:nodoc:all
    protected
      def execute_callback_type_on_instance(callback_type, instance)
        callbacks = self.send callback_type
        return if callbacks.nil?
        (callbacks.is_a?(Array) ? callbacks : [callbacks]).each { |callback| execute_callback_on_instance(callback, instance) }
      end

      def execute_callback_on_instance(callback, instance)
        if instance.respond_to? callback
          instance.send callback
        else
          logger.warn "Instance #{instance.inspect} does not respond to callback #{callback} defined on workflow node '#{name}' in process '#{process.name}'"
        end
      end

      def validate_callbacks(callback_type)
        callbacks = self.send(callback_type)
        valid = (callbacks.is_a?(Array) ? callbacks : [callbacks]).all? { |c| callback_is_valid?(c) }
        self.errors.add(callback_type, "must be nil, symbols, strings, or arrays of them") unless valid
      end

      def callback_is_valid?(callback)
        callback.nil? || callback.is_a?(String) || callback.is_a?(Symbol)
      end
    end
  end
end