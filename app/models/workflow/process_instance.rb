class Workflow::ProcessInstance < ActiveRecord::Base
  belongs_to :instance, :polymorphic => true
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "process_instance_id"
  has_many :nodes, :through => :process_instance_nodes
  has_one :node, :through => :process_instance_nodes
  alias_method :state, :node
  
  scope :process_named, lambda { |name| joins(:process).where('workflow_processes.name = ? ', name) }
  
  # Only worried about sequential processes for the time
  def transition!(name)
    transitions = if name.is_a? Array
      name.map{|n| node.transitions(true).named(n.to_s)}.flatten.uniq
    else
      node.transitions.named(name.to_s)
    end    
    raise Workflow::NoSuchTransition if transitions.empty?

    transition_to_take = transitions.first
    new_node = transition_to_take.to_node      
    
    process_instance_node = self.process_instance_nodes.first
    
    # TODO: return here unless all guards pass
    
    node.execute_exit_callbacks self
    transition_to_take.execute_callbacks self
    process_instance_node.node = new_node
    process_instance_node.save!
    self.reload
    new_node.execute_enter_callbacks self

    new_node
  end
end
