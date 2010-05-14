# This class joins any model, polymorphically, with a workflow Process.
class Workflow::ProcessInstance < ActiveRecord::Base
  belongs_to :instance, :polymorphic => true
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "process_instance_id", :dependent => :destroy
  has_many :nodes, :through => :process_instance_nodes
  has_one :node, :through => :process_instance_nodes
  alias_method :state, :node
  
  scope :process_named, lambda { |name| joins(:process).where('workflow_processes.name = ? ', name) }
  
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
  def transition!(name)
    transitions = if name.is_a? Array
      name.map{|n| node.transitions(true).named(n.to_s)}.flatten.uniq
    else
      node.transitions.named(name.to_s)
    end    
    raise Workflow::NoSuchTransition if transitions.empty?

    transition_to_take = transitions.first
    return false unless transition_to_take.guards_pass?(instance)
    
    new_node = transition_to_take.to_node      
    process_instance_node = self.process_instance_nodes.first
    node.execute_exit_callbacks self
    node.cancel_scheduled_actions self
    transition_to_take.execute_callbacks self
    process_instance_node.node = new_node
    process_instance_node.save!
    self.reload
    new_node.schedule_actions self
    new_node.execute_enter_callbacks self

    new_node
  end
end
