# A Task is something that must be done, usually by a human being.  When it is completed, the instance
# is transitioned to the next in the workflow along the 'completed' transition.
#
# This is the default implementation of a task created by an TaskNode.
# 
# Subclasses may wish to override assigned_to= to use business logic to create relationships
# between tasks and users or groups.
class Workflow::Task < ActiveRecord::Base
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  belongs_to :process_instance, :class_name => "Workflow::ProcessInstance", :foreign_key => "process_instance_id"
  
  # Returns true if this task has been completed (time stored in completed_at)
  def completed?
    !!completed_at
  end
  
  # Marks a task as complete by setting completed_at and advancing the process instance along the 'completed' transition.
  def complete!
    self.completed_at = Time.now
    process_instance.transition! :completed
  end
end
