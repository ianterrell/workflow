# This is a node that automatically creates a Task when the instance enters.
# 
# On entry, it will create a Task using the following algorithm:
# 1. If the node does not have a custom_class set, it will create a Task.
# 2. If the node does have a custom_class and it exists, it will instantiate it.
# 3. If the custom_class does not exist, it raises BadTaskClass.
#
# The Task or custom_class is instantiated with a hash of attributes, including the node
# the process instance, and the node's 'assign_to' field.  Subclasses of Task can 
# override their assigned_to= method to take the 'assign_to' string and do something
# meaningful with it, like create relationships to users or groups.
class Workflow::TaskNode < Workflow::Node
  has_many :tasks, :class_name => "Workflow::Task", :foreign_key => "node_id"
  
  def execute_enter_callbacks(process_instance) #:nodoc:
    super
    create_task process_instance
  end
  
protected
  def create_task(process_instance) #:nodoc:
    clazz = if custom_class.blank?
      Workflow::Task
    else
      custom_class.constantize rescue raise Workflow::BadTaskClass
    end
    clazz.create :node => self, :process_instance => process_instance, :assigned_to => assign_to
  end
end
