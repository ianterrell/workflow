class Workflow::Node < ActiveRecord::Base
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  has_many :transitions, :class_name => "Workflow::Transition", :foreign_key => "from_node_id"
  has_many :incoming_transitions, :class_name => "Workflow::Transition", :foreign_key => "to_node_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "node_id"
  has_many :process_instances, :through => :process_instance_nodes
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :process_id
end
