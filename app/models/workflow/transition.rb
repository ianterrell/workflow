class Workflow::Transition < ActiveRecord::Base
  belongs_to :from_node, :class_name => "Workflow::Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Workflow::Node", :foreign_key => "to_node_id"
  
  validates_presence_of :name
end
