# This is a join model to link ProcessInstance with Node, in advance of supporting parallel workflow branches.
class Workflow::ProcessInstanceNode < ActiveRecord::Base
  belongs_to :process_instance, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_instance_id"
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  has_many :transitions, :through => :node

  scope :for_node, lambda { |node| where('node_id = ? ', node.id) }
  scope :for_instance, lambda { |instance| where('process_instance_id = ? ', instance.id) }

  # The following scope, much simpler, should work, but doesn't.  This is related to the following issue:  https://rails.lighthouseapp.com/projects/8994/tickets/3684-invalid-sql-is-created-when-you-set-has_one-through-association-to-join
  # This should be followed up and switched out when ActiveRecord gets patched appropriately.
  # scope :with_transition_named, lambda { |name| joins(:transitions).where('workflow_transitions.name = ?', name) }
  scope :with_transition_named, lambda { |name| { :conditions => [ 'workflow_transitions.name = ?', name ], :joins => 'JOIN workflow_nodes ON workflow_nodes.id = workflow_process_instance_nodes.node_id JOIN workflow_transitions ON workflow_transitions.from_node_id = workflow_nodes.id'}}
end
