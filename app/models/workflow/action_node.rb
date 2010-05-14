# This is a node that automatically performs an action when the instance enters.
# 
# On entry, it will create an action using the following algorithm:
# 1. If the node has a custom_class set, it will attempt to instantiate that class and call perform on it.
# 2. If the model on the workflow responds to the name of the node, 
#    it will create an Action that will send that signal to the model, and that is performed.
# 3. If a class named '<name>Action' exists, where <name> is the name of this node, it is instantiated and perform is called.
# 4. If none of the above are true, it raises a NoWayToPerformAction error.
class Workflow::ActionNode < Workflow::Node
  has_many :actions, :class_name => "Workflow::Action", :foreign_key => "node_id"

  def execute_enter_callbacks(process_instance) #:nodoc:
    super
    create_action process_instance
  end

protected
  def create_action(process_instance) #:nodoc:
    clazz = if !custom_class.blank?
      custom_class.constantize
    elsif process_instance.instance.respond_to?(name)
      Workflow::Action
    elsif Workflow.custom_class_exists?("#{name}_action")
      Workflow.custom_class("#{name}_action")
    else
      raise Workflow::NoWayToPerformAction
    end
    action = clazz.create :node => self, :process_instance => process_instance
    raise Workflow::CustomActionDoesntQuack unless action.respond_to? :perform
    action.perform
  end
end