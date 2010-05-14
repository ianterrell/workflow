# The Workflow::Process forms the basis of an executable business process by grouping nodes together
# into a named container.
class Workflow::Process < ActiveRecord::Base
  has_many :process_instances, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_id", :dependent => :destroy
  has_many :nodes, :class_name => "Workflow::Node", :foreign_key => "process_id", :dependent => :destroy
  has_one :start_node, :class_name => "Workflow::Node", :foreign_key => "process_id", :conditions => { :start => true }

  validates_presence_of :name
  validates_uniqueness_of :name
  
  scope :named, lambda { |name| where(:name => name) }
end
