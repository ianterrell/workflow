class Workflow::ProcessInstance < ActiveRecord::Base
  belongs_to :instance, :polymorphic => true
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "process_instance_id"
  has_many :nodes, :through => :process_instance_nodes
end
