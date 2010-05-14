module Workflow
  # Workflow migrations are the preferred way to create and manage your workflow processes.  They behave similarly to
  # the database migrations you're used to using with Rails, although rather than manipulating the schema they're only
  # manipulating data.
  # 
  # This is the base class that your individual migrations should subclass.
  # 
  # Create a migration like so:
  #   rails generate workflow:migration name_of_migration
  # 
  # Migration examples:
  #
  #   class CreateProcessMigration < Workflow::Migration
  #     def self.up
  #       create_process "Publication Process" do
  #         state :start, :start_state => true do
  #           transition :go, :to => :holding_pattern
  #         end
  #   
  #         wait_state :holding_pattern, :transition_to => :ready?, :after => 7.days
  #   
  #         decision :ready? do
  #           transition :yes, :to => :process
  #           transition :no, :to => :holding_pattern
  #         end
  # 
  #         action :process do
  #           transition :completed => :approval
  #         end
  # 
  #         task :approval, :custom_class => "MyApprovalTask", :assign_to => "manager" do
  #           transition :completed, :to => :end
  #           timer :perform => :remind_manager, :every => 1.day, :up_to => 3.times
  #         end
  # 
  #         state :end
  #       end
  #     end
  #  end
  class Migration    
    class << self
      # The method your specific migration needs to define to create or manage your workflow processes.
      # 
      # Example:
      #   class CreateProcessMigration < Workflow::Migration
      #     def self.up
      #       create_process "My Process" do
      #         ...
      #       end
      #     end
      #   end
      def up
        raise Error.new("Your migration must provide the class level 'up' method.")
      end
      
      # Workflow processes are data, so reversing migrations could be really dangerous and could potentially
      # lose a lot of information.  It's not recommended to even define this method on your subclasses.  
      # But you're welcome to try.
      def down
        raise Error.new("Your migration must provide the class level 'down' method.")
      end
    
      # This creates a workflow process with the given name.  The block passed to it will be executed to create
      # the various subparts of the process.
      #
      # If the process does not end up with a start state, an Error is raised.
      #
      # Example:
      #   create_process "Publication Process" do
      #     state :draft, :start_state => true do
      #       ...
      #     end
      #   end
      def create_process(name)
        @node_blocks = {}
        Workflow::Process.transaction do
          @process = Workflow::Process.create! :name => name
          yield if block_given?
          @node_blocks.each_pair { |node, block| @node = node; block.call }
          raise Error.new("The process '#{@process.name}' must have a start state.") if @process.reload.start_node.nil?
        end
      end
      
      # Destroys the process with the given name.
      def destroy_process(name)
        Workflow::Process.find_by_name(name).destroy
      end
      
      # Creates a Node object with the given name to exist in the current process.  
      # The block passed to it will be used to create Transition and ScheduledActionGenerator objects.
      #
      # Raises an Error if not called from within a valid create_process or update_process block.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process.
      # 
      # Optional:
      # * :start_state -- If true, this will be used as the process's start state
      # * :enter -- a single or multiple callbacks to be executed on the model when it enters the state
      # * :exit -- a single or multiple callbacks to be executed on the model when it exits the state
      # * Block to create transitions and timers
      #
      # Examples:
      #   state "basic"
      #
      #   state :draft, :start_state => true, :exit => [:prepare_site, :call_webservice] do
      #     transition :complete, :to => :final
      #   end
      #
      #   state :published, :enter => :notify_manager
      def state(name, options={}, &block)
        create_node Workflow::Node, name, options, &block
      end
      
      # Creates a DecisionNode object with the given name to exist in the current process.  
      # The block passed to it will be used to create Transition objects.
      #
      # Raises an Error if not called from within a valid create_process or update_process block.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process. 
      #   The name of the state can influence how the DecisionNode decides which transition to take.  See that class for details.
      # 
      # Optional:
      # * Takes all of the same options as state
      # * :decision_class -- if specified, sets the custom_class field on the DecisionNode to the class to
      #   be used to make the decision.  See that class for details.
      #
      # Examples:
      #   decision :ready? do
      #     transition :yes, :to => :process
      #     transition :no, :to => :holding_pattern
      #   end
      #
      #   decision :its_compliated, :decision_class => "MyHardDecision" do
      #     ...
      #   end
      def decision(name, options={}, &block)
        options[:class_name] = options[:decision_class]
        create_node Workflow::DecisionNode, name, options, &block
      end

      # Creates a TaskNode object with the given name to exist in the current process.  
      # The block passed to it will be used to create Transition and ScheduledActionGenerator objects.  
      # 
      # One transition named 'completed' should always be defined on task nodes, which will be automatically followed
      # when the task is completed.  See TaskNode for details.
      #
      # Raises an Error if not called from within a valid create_process or update_process block.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process.
      #   The name of the state can influence how the TaskNode creates a task.  See that class for details.
      # 
      # Optional:
      # * Takes all of the same options as state
      # * :task_class -- if specified, sets the custom_class field on the TaskNode to the class to
      #   be used to create the task.  This is often preferable so that business logic can be used to
      #   relationally associate this task with users or groups.  See that class for details.
      #
      # Examples:
      #   task :do_something do
      #     transition :completed, :to => :all_done
      #   end
      #
      #   task :do_something_special, :task_class => "MyCustomTask" do
      #     transition :completed, :to => :all_done
      #   end
      def task(name, options={}, &block)
        options[:class_name] = options[:task_class]
        create_node Workflow::TaskNode, name, options, &block
      end

      # Creates an ActionNode object with the given name to exist in the current process.  
      # The block passed to it will be used to create Transition objects.  
      # 
      # One transition named 'completed' should always be defined on action nodes, which will be automatically followed
      # when the action is performed.  See ActionNode for details.
      #
      # Raises an Error if not called from within a valid create_process or update_process block.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process.
      #   The name of the state can influence how the ActionNode creates an action.  See that class for details.
      # 
      # Optional:
      # * Takes all of the same options as state
      # * :action_class -- if specified, sets the custom_class field on the ActionNode to the class to
      #   be used to create the action.  Subclasses are responsible for calling complete! from their perform
      #   method.  See that class for details.
      #
      # Examples:
      #   action :do_something do
      #     transition :completed, :to => :all_done
      #   end
      #
      #   action :do_something_special, :action_class => "MyCustomAction" do
      #     transition :completed, :to => :all_done
      #   end
      def action(name, options={}, &block)
        options[:class_name] = options[:action_class]
        create_node Workflow::ActionNode, name, options, &block
      end
      
      # Creates a node based on a class that your application defines.
      # The block passed to it will be used to create Transition and ScheduledActionGenerator objects.  
      # 
      # Raises an Error if not called from within a valid create_process or update_process block.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process.
      # * :node_class -- String name of the class of the node.  This class should be already defined and descend from Workflow::Node or a subclass of it.
      # 
      # Optional:
      # * Takes all of the same options as state
      #
      # Examples:
      #   custom :my_node, :node_class => "MyCustomNode" do
      #     transition :go, :to => :next
      #   end
      def custom(name, options={}, &block)
        raise Error.new("The custom node '#{name}' must specify its class with :node_class.") unless options[:node_class]
        clazz = begin
          options[:node_class].constantize
        rescue NameError
          raise Error.new("Custom node classes must be defined; the class '#{options[:node_class]}' in the node '#{name}' can not be found.")
        end
        raise Error.new("Custom node classes must descend from Workflow::Node; the class '#{options[:node_class]}' in the node '#{name}' does not.") unless clazz.ancestors.include?(Workflow::Node)
        create_node clazz, name, options, &block
      end
      
      # Creates a wait state that your workflow will pause in for the specified length of time.
      # This is merely a shortcut for defining a state with one transition and a timer to move it along.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the state.  Must be unique in the process.
      # * :transition_to -- Symbol or string to represent the node to transition to
      # * :after -- Duration to wait in this state, i.e. 5.minutes or 7.days
      #
      # Examples:
      #   wait_state :holding_pattern, :transition_to => :ready?, :after => 7.days
      #
      # Is equivalent to:
      #   state :holding_pattern do
      #     transition :continue, :to => <:transition_to>
      #     timer :take_transition => :continue, :after => <:after>
      #   end
      def wait_state(name, options)
        raise Error.new("The wait state '#{name}' in the process '#{@process.name}' needs to specify a node to transition to with :transition_to.") unless options[:transition_to]
        raise Error.new("The wait state '#{name}' in the process '#{@process.name}' needs to specify an interval to wait with :after.") unless options[:after]
        state name do
          transition :continue, :to => options[:transition_to]
          timer :take_transition => :continue, :after => options[:after]
        end
      end
      
      # Creates a transition from the current node to another node in the process.
      # 
      # Required:
      # * name parameter -- Symbol or string to represent the name of the transition.  Must be unique in the state.
      # * :to -- Symbol or string that identifies which node to transition to
      #
      # Optional:
      # * :on_transition -- callback methor or methods to be executed on the model when it takes this transition.
      #
      # Examples:
      #   state :war do
      #     transition :advance, :to => :front_lines
      #     transition :retreat, :to => :cover, :on_transition => :call_for_help
      #   end
      def transition(name, options)
        raise Error.new("The transition '#{name}' in the node '#{@node.name}' must have a :to option specifying where it goes.") unless options[:to]
        raise Error.new("The node '#{options[:to]}' referenced in the transition '#{name}' in the node '#{@node.name}' does not exist in the process '#{@node.process.name}'.") unless (to_node = @process.nodes(true).named(options[:to].to_s).first)

        @node.transitions.create! :name => name.to_s, :to_node => to_node, :callbacks => options[:on_transition]
      end
      
      # Creates a timed action on the node to take a transition or execute an action.
      # 
      # This is implemented by creating a ScheduledActionGenerator on the node which creates ScheduledAction instances when models
      # enter the node.  If the :generator_class option is specified, that class is used instead of the default implementation.  
      # Any custom generator should descend from ScheduledActionGenerator or a subclass.
      # 
      # <b>Timed Transitions</b>
      # 
      # To use a timer to take a transition, the options :take_transition and :after are both required.  The former should be
      # a symbol or string that identifies a node in the process, and the latter defines the interval to wait.
      #
      # Example:
      #   state :wait_a_while do
      #     transition :go, :to => :next
      #     timer :take_transition => :go, :after => 5.minutes
      #   end
      # 
      # <b>Timed Actions</b>
      # 
      # To use a timer to execute an action, the :perform option should be specified along with the interval.
      # The value assigned to :perform is used to determine what sort of action to execute, whether a default ScheduledAction or
      # a custom class; see that class for details.  Use :action_class to override the custom_class on the generator.
      #
      # Actions can be scheduled for execute one time with :after, or to execute repeatedly with :every.  To limit the number
      # of repetitions, include :up_to as specified in the example.
      # 
      # Examples:
      # 
      #   state :approval do
      #     transition :approve, :to => :published
      #     transition :reject, :to => :draft
      #     timer :perform => :update_rss, :every => 10.minutes
      #     timer :perform => :send_reminder_email, :every => 2.days, :up_to => 3.times
      #     timer :perform => :notify_manager_of_tardiness, :after => 1.week
      #     timer :perform => :destroy_the_system, :action_class => "BigRedButton", :after => 1.month
      #   end
      def timer(options)
        attributes = { :node => @node }
        attributes[:custom_class] = options[:action_class]
        attributes[:interval] = options[:after] if options[:after]
        if options[:every]
          attributes[:interval] = options[:every] 
          attributes[:repeat] = true
          if options[:up_to]
            raise Error.new("A timer in the node '#{@node.name}' specified a repeat count without using an enumerator (use 3.times rather than 3).") unless options[:up_to].is_a?(Enumerable::Enumerator)
            attributes[:repeat_count] = options[:up_to].try(:max).try(:+, 1)
          end
        end
        clazz = if options[:generator_class]
          begin
            options[:generator_class].constantize
          rescue NameError
            raise Error.new("Custom generator classes must be defined; the class '#{options[:generator_class]}' in the node '#{@node.name}' can not be found.")
          end
        else
          Workflow::ScheduledActionGenerator
        end
        raise Error.new("Custom generator classes must descend from Workflow::ScheduledActionGenerator; the class '#{options[:generator_class]}' in the node '#{@node.name}' does not.") unless clazz.ancestors.include?(Workflow::ScheduledActionGenerator)
        attributes[:transition] = options[:take_transition].to_s if options[:take_transition]
        attributes[:action] = options[:perform].to_s if options[:perform]
        raise Error.new("A timer in the node '#{@node.name}' needs an interval, specify with either :after or :every.") unless attributes[:interval]
        raise Error.new("A timer in the node '#{@node.name}' needs either an action to perform (use :perform) or a transition to take (use :take_transition).") unless attributes[:action] || attributes[:transition]
        raise Error.new("A timer in the node '#{@node.name}' is trying to specify an action and a transition -- it can only do exactly one.") if attributes[:action] && attributes[:transition]
        clazz.create! attributes
      end
      
      # This is not meant to be called directly, although if you want, you can!
      def create_node(clazz, name, options={}, &block) #:nodoc:
        raise Error.new("The node '#{name}' must be defined within a process.") unless @process
        node = clazz.create! :process => @process.reload, :name => name.to_s, :start => options[:start_state], :enter_callbacks => options[:enter], :exit_callbacks => options[:exit], :custom_class => options[:class_name], :assign_to => options[:assign_to]
        @node_blocks[node] = block if block_given?
      end
    end
    
    # Raised when an error in a migration happens.
    class Error < StandardError; end
  end
end