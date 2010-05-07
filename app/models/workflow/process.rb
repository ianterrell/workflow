class Workflow::Process < ActiveRecord::Base
  has_many :process_instances, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_id"
  has_many :nodes, :class_name => "Workflow::Node", :foreign_key => "process_id"

  validates_presence_of :name
end
