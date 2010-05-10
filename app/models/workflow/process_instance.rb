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
    name = name.to_s
    if node.transitions.named(name).empty?
      raise Workflow::NoSuchTransition
    else
      # TODO:  Callbacks, guards, etc
      process_instance_node = self.process_instance_nodes.first
      process_instance_node.node = node.transitions.named(name).first.to_node
      process_instance_node.save!
      self.reload
    end
  end
end
