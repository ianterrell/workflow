# This class is the basic node on the process graph, and represents a state that the instance
# can enter in the workflow.  This class acts as a simple state that does nothing special by default,
# while subclasses implement specific behavior.
# 
# Nodes may have enter_callbacks and exit_callbacks defined which represent methods that 
# will be executed on the model when it enters and exits this node, respectively (behavior defined in Callbacks).
# Nodes may also have ScheduledActionGenerator instances associated with them that provide timed behavior.
class Workflow::Node < ActiveRecord::Base
  include Workflow::Callbacks
  
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  has_many :transitions, :class_name => "Workflow::Transition", :foreign_key => "from_node_id", :dependent => :destroy
  has_many :incoming_transitions, :class_name => "Workflow::Transition", :foreign_key => "to_node_id", :dependent => :destroy
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "node_id", :dependent => :destroy
  has_many :process_instances, :through => :process_instance_nodes
  
  has_many :scheduled_action_generators, :class_name => "Workflow::ScheduledActionGenerator", :foreign_key => "node_id", :dependent => :destroy
  has_many :scheduled_actions, :through => :scheduled_action_generators
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :process_id
  
  validate :only_one_start_node
  
  has_callbacks :enter, :exit
  
  scope :named, lambda { |name| where(:name => name) }
  
  # This creates ScheduledAction instances for all of the generators associated with this node.
  def schedule_actions(process_instance)
    self.scheduled_action_generators.each do |generator|
      generator.generate process_instance
    end
  end
  
  # This sends the cancel! signal to all scheduled actions tied to this node and the instance sent.
  def cancel_scheduled_actions(process_instance)
    scheduled_actions.where(:process_instance_id => process_instance.id).each { |a| a.cancel! }
  end
  
protected
  def only_one_start_node #:nodoc:
    self.errors.add(:base, I18n.t('workflow.errors.start_node_exists')) if self.start? && process.start_node && process.start_node != self
  end
end
