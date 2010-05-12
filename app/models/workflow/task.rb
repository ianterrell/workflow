class Workflow::Task < ActiveRecord::Base
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  belongs_to :process_instance, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_instance_id"
  
  def completed?
    !!completed_at
  end
  
  def complete!
    self.completed_at = Time.now
    process_instance.transition! :completed
  end
end
