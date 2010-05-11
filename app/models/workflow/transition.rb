class Workflow::Transition < ActiveRecord::Base
  include Workflow::Callbacks
  
  belongs_to :from_node, :class_name => "Workflow::Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Workflow::Node", :foreign_key => "to_node_id"
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :from_node_id
  
  has_callbacks
  
  scope :named, lambda { |name| where(:name => name) }
  
  delegate :process, :to => :from_node
end
