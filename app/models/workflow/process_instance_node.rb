# This is a join model to link ProcessInstance with Node, in advance of supporting parallel workflow branches.
class Workflow::ProcessInstanceNode < ActiveRecord::Base
  belongs_to :process_instance, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_instance_id"
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
end
