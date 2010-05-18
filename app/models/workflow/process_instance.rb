# This class joins any model, polymorphically, with a workflow Process.
class Workflow::ProcessInstance < ActiveRecord::Base
  belongs_to :instance, :polymorphic => true
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "process_instance_id", :dependent => :destroy

  has_many :nodes, :through => :process_instance_nodes
  has_one :node, :through => :process_instance_nodes
  alias_method :state, :node

  # TODO: Spec this out
  has_many :transitions, :finder_sql => 'SELECT workflow_transitions.* FROM workflow_transitions JOIN workflow_nodes ON workflow_transitions.from_node_id = workflow_nodes.id JOIN workflow_process_instance_nodes ON workflow_process_instance_nodes.node_id = workflow_nodes.id WHERE workflow_process_instance_nodes.id in (#{self.process_instance_nodes.map(&:id)});', :uniq => true
  
  scope :process_named, lambda { |name| joins(:process).where('workflow_processes.name = ? ', name) }
  
  # TODO:  Update doc below for fork specific stuff
  #
  # This method attempts to move the instance along the transition named out of the current node.
  # 
  # It accepts either a single transition name as an argument, or an array of them.  In the case of
  # an array, it uses the first one it finds.
  # 
  # If a transition was found and it has 'guards' defined, this method checks all of them. 
  # If they all return true it is determined that the model can take this
  # transition.  If they do not all return true, this method returns false and execution is halted.
  #
  # If the guards pass, this method then does the following:
  # 1. Execute the exit callbacks on the current node
  # 2. Cancel all the ScheduledAction instances on the current node for the instance
  # 3. Executes the Transition's callbacks
  # 4. Saves itself to the new node
  # 5. Creates new ScheduledAction instances for the new node
  # 6. Executes the enter callbacks on the new node
  #
  # If no valid transition is found, it raises NoSuchTransition
  # 
  # Workflow currently only supports sequential processes.  Forks and joins will change this method.
  def transition!(name, disambiguation = nil)
    if disambiguation.nil?
      possible_pins = self.process_instance_nodes.with_transition_named(name.to_s)
      raise Workflow::AmbiguousTransition.new("More than one transition named '#{name}' was found.") if possible_pins.size > 1
      process_instance_node = possible_pins.first
    elsif disambiguation.is_a?(Workflow::ProcessInstanceNode) && disambiguation.process_instance == self
      process_instance_node = disambiguation
    elsif disambiguation.is_a?(Workflow::Node) && disambiguation.process == process
      process_instance_node = process_instance_nodes.for_node(disambiguation).first
    else
      raise Workflow::NoSuchTransition.new("Disambiguation passed is not a ProcessInstanceNode that belongs to this ProcessInstance or a Node in this Process (transition named '#{name}').")
    end
    raise Workflow::NoSuchTransition.new("Could not find a transition named '#{name}' from current nodes.") unless process_instance_node
    
    from_node = process_instance_node.node
    transitions = from_node.transitions.named(name.to_s)
    raise Workflow::NoSuchTransition if transitions.empty?
    transition_to_take = transitions.first
    to_node = transition_to_take.to_node
    
    # Transition guards pass?
    return false unless transition_to_take.guards_pass?(instance)
    
    # Callback order is very specific.
    from_node.execute_exit_callbacks self
    from_node.cancel_scheduled_actions self
    transition_to_take.execute_callbacks self
    process_instance_node.node = to_node
    process_instance_node.save!
    self.reload
    to_node.schedule_actions self
    to_node.execute_enter_callbacks self

    to_node
  end
  
protected
  def process_instance_nodes_with_transition
    
  end
end