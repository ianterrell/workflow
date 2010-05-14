module Workflow
  class Migration    
    class << self
      def up
        raise Workflow::Migration::UpNotDefined
      end
      
      def down
        raise Workflow::Migration::DownNotDefined
      end
    
      def create_process(name)
        @node_blocks = {}
        Workflow::Process.transaction do
          @process = Workflow::Process.create! :name => name
          yield if block_given?
          @node_blocks.each_pair { |node, block| @node = node; block.call }
          raise ProcessMustHaveStartState if @process.reload.start_node.nil?
        end
      end
      
      def destroy_process(name)
        Workflow::Process.find_by_name(name).destroy
      end
      
      def state(name, options={}, &block)
        create_node Workflow::Node, name, options, &block
      end
      
      def decision(name, options={}, &block)
        options[:class_name] = options[:decision_class]
        create_node Workflow::DecisionNode, name, options, &block
      end

      def task(name, options={}, &block)
        options[:class_name] = options[:task_class]
        create_node Workflow::TaskNode, name, options, &block
      end

      def action(name, options={}, &block)
        options[:class_name] = options[:action_class]
        create_node Workflow::ActionNode, name, options, &block
      end
      
      def custom(name, options={}, &block)
        raise CustomNodeMustDefineClass.new("The custom node '#{name}' must specify its class with :node_class.") unless options[:node_class]
        clazz = begin
          options[:node_class].constantize
        rescue NameError
          raise CustomNodeClassDoesNotExist.new("Custom node classes must be defined; the class '#{options[:node_class]}' in the node '#{name}' can not be found.")
        end
        raise CustomNodeMustDescendFromWorkflowNode.new("Custom node classes must descend from Workflow::Node; the class '#{options[:node_class]}' in the node '#{name}' does not.") unless clazz.ancestors.include?(Workflow::Node)
        create_node clazz, name, options, &block
      end
      
      def wait_state(name, options)
        raise WaitStateNeedsTransitionTo.new("The wait state '#{name}' in the process '#{@process.name}' needs to specify a node to transition to with :transition_to.") unless options[:transition_to]
        raise WaitStateNeedsInterval.new("The wait state '#{name}' in the process '#{@process.name}' needs to specify an interval to wait with :after.") unless options[:after]
        state name do
          transition :continue, :to => options[:transition_to]
          timer :take_transition => :continue, :after => options[:after]
        end
      end
      
      def transition(name, options)
        raise TransitionMustGoSomewhere.new("The transition '#{name}' in the node '#{@node.name}' must have a :to option specifying where it goes.") unless options[:to]
        raise NodeDoesNotExist.new("The node '#{options[:to]}' referenced in the transition '#{name}' in the node '#{@node.name}' does not exist in the process '#{@node.process.name}'.") unless (to_node = @process.nodes(true).named(options[:to].to_s).first)

        @node.transitions.create! :name => name.to_s, :to_node => to_node, :callbacks => options[:on_transition]
      end
      
      def timer(options)
        attributes = { :node => @node }
        attributes[:interval] = options[:after] if options[:after]
        if options[:every]
          attributes[:interval] = options[:every] 
          attributes[:repeat] = true
          if options[:up_to]
            raise TimerRepeatCountMustBeEnumerator.new("A timer in the node '#{@node.name}' specified a repeat count without using an enumerator (use 3.times rather than 3).") unless options[:up_to].is_a?(Enumerable::Enumerator)
            attributes[:repeat_count] = options[:up_to].try(:max).try(:+, 1)
          end
        end
        clazz = if options[:generator_class]
          begin
            options[:generator_class].constantize
          rescue NameError
            raise CustomGeneratorClassDoesNotExist.new("Custom generator classes must be defined; the class '#{options[:generator_class]}' in the node '#{@node.name}' can not be found.")
          end
        else
          Workflow::ScheduledActionGenerator
        end
        raise CustomGeneratorMustDescendFromWorkflowGenerator.new("Custom generator classes must descend from Workflow::ScheduledActionGenerator; the class '#{options[:generator_class]}' in the node '#{@node.name}' does not.") unless clazz.ancestors.include?(Workflow::ScheduledActionGenerator)
        attributes[:transition] = options[:take_transition].to_s if options[:take_transition]
        attributes[:action] = options[:perform].to_s if options[:perform]
        raise TimerNeedsInterval.new("A timer in the node '#{@node.name}' needs an interval, specify with either :after or :every.") unless attributes[:interval]
        raise TimerNeedsActionOrTransition.new("A timer in the node '#{@node.name}' needs either an action to perform (use :perform) or a transition to take (use :take_transition).") unless attributes[:action] || attributes[:transition]
        raise TimerNeedsExactlyOneActionOrTransition.new("A timer in the node '#{@node.name}' is trying to specify an action and a transition -- it can only do exactly one.") if attributes[:action] && attributes[:transition]
        clazz.create! attributes
      end
      
      # This is not meant to be called directly, although if you want, you can!
      def create_node(clazz, name, options={}, &block)
        raise NodeMustBeWithinProcess.new("The node '#{name}' must be defined within a process.") unless @process
        node = clazz.create! :process => @process.reload, :name => name.to_s, :start => options[:start_state], :enter_callbacks => options[:enter], :exit_callbacks => options[:exit], :custom_class => options[:class_name], :assign_to => options[:assign_to]
        @node_blocks[node] = block if block_given?
      end
    end
    
    class Error < StandardError; end
    class UpNotDefined < Error; end
    class DownNotDefined < Error; end
    class ProcessMustHaveStartState < Error; end
    class NodeMustBeWithinProcess < Error; end
    class TransitionMustGoSomewhere < Error; end
    class NodeDoesNotExist < Error; end
    class TimerNeedsInterval < Error; end
    class TimerNeedsActionOrTransition < Error; end
    class TimerNeedsExactlyOneActionOrTransition < Error; end
    class TimerRepeatCountMustBeEnumerator < Error; end
    class WaitStateNeedsTransitionTo < Error; end
    class WaitStateNeedsInterval < Error; end
    class CustomNodeMustDefineClass < Error; end
    class CustomNodeClassDoesNotExist < Error; end
    class CustomNodeMustDescendFromWorkflowNode < Error; end
    class CustomGeneratorClassDoesNotExist < Error; end
    class CustomGeneratorMustDescendFromWorkflowGenerator < Error; end
  end
end