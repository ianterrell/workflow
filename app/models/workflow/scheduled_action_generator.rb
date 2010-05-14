# This is a node that scheduled automatically executing actions when an instance enters its node.
# 
# On entry, it will create a scheduled action using the following algorithm:
# 1. If the node has a custom_class set, it will attempt to instantiate that class and schedules its execution.
# 2. If 'transition' is set, it creates a ScheduledAction to take that transition and schedules its execution.
# 3. If the model on the workflow responds to the 'action' field
#    it creates a ScheduledAction that will send that signal to the model, and schedules its execution.
# 3. If a class named '<name>Action' exists, where <name> is the name of this node, it is instantiated and the generator schedules its execution.
# 4. If none of the above are true, it raises a NoWayToPerformAction error. 
#
# On instance exit, all ScheduledAction instances are canceled.
# 
# For action based generators, the generator can be set to generate repeat actions by using 'repeat,' with a maximum
# number of potential executions by using 'repeat_count.'  Transition based generators are not designed to support
# repeating.
# 
# Subclasses can easily define their own scheduling algorithm by overriding scheduled_time.
class Workflow::ScheduledActionGenerator < ActiveRecord::Base
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  has_many :scheduled_actions, :class_name => "Workflow::ScheduledAction", :foreign_key => "generator_id", :dependent => :destroy
  
  # Generates the ScheduledAction or custom_class based on the algorithm described above, and schedules its execution
  # for the time returned by scheduled_time
  def generate(process_instance)
    clazz = if !custom_class.blank?
      custom_class.constantize
    elsif transition || (action && process_instance.instance.respond_to?(action))
      Workflow::ScheduledAction
    elsif Workflow.custom_class_exists?("#{action}_action")
      Workflow.custom_class("#{action}_action")
    else
      raise Workflow::NoWayToPerformAction
    end
    clazz.create :generator => self, :node => node, :process_instance => process_instance, :scheduled_for => self.scheduled_time(process_instance)
  end
  
protected
  # Default implementation schedules the execution for interval.from_now
  def scheduled_time(process_instance)
    interval.from_now
  end
end
