class Workflow::Node < ActiveRecord::Base
  include Workflow::Callbacks
  
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
  has_many :transitions, :class_name => "Workflow::Transition", :foreign_key => "from_node_id"
  has_many :incoming_transitions, :class_name => "Workflow::Transition", :foreign_key => "to_node_id"
  
  has_many :process_instance_nodes, :class_name => "Workflow::ProcessInstanceNode", :foreign_key => "node_id"
  has_many :process_instances, :through => :process_instance_nodes
  
  has_many :scheduled_action_generators, :class_name => "Workflow::ScheduledActionGenerator", :foreign_key => "node_id"
  has_many :scheduled_actions, :through => :scheduled_action_generators
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :process_id
  
  has_callbacks :enter, :exit
  
  def schedule_actions(process_instance)
    self.scheduled_action_generators.each do |generator|
      generator.generate process_instance
    end
  end
  
  def cancel_scheduled_actions(process_instance)
    scheduled_actions.where(:process_instance_id => process_instance.id).each { |a| a.cancel! }
  end
end
