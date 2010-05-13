class Workflow::ScheduledActionGenerator < ActiveRecord::Base
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  has_many :scheduled_actions, :class_name => "Workflow::ScheduledAction", :foreign_key => "generator_id"
  
  def generate(process_instance)
    scheduled_actions.create :node => node, :process_instance => process_instance, :scheduled_for => interval.from_now
  end
end
