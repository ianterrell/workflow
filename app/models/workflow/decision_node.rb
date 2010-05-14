# This is a node that automatically decides which transition to take when the instance enters.
# 
# On entry, it will try to decide based on the following algorithm:
# 1. If the node has a custom_class set, it will attempt to instantiate that class and call transition_to_take on it.
# 2. If the model on the workflow responds to the name of the node, 
#    it will send that signal to the model to determine which transition to take.
# 3. If a class named '<name>Decision' exists, where <name> is the name of this node, it is instantiated and transition_to_take is called.
# 4. If none of the above are true, it raises a NoWayToMakeDecision error.
#
# If the value returned by the method on the model or the transition_to_take method on the instance used is a boolean value,
# the workflow system will attempt to transition along a transition named "yes" and "true" for TrueClass, and "no" and "false"
# for FalseClass.  In this way your workflow transitions can be more nicely named.
class Workflow::DecisionNode < Workflow::Node
  def execute_enter_callbacks(process_instance) #:nodoc:
    super
    transition process_instance
  end
  
protected 
  def transition(process_instance) #:nodoc:
    process_instance.transition! transition_to_take(process_instance.instance)
  end

  def transition_to_take(instance) #:nodoc:
    value = if !custom_class.blank?
      decide_with_class custom_class.constantize, instance
    elsif instance.respond_to? name
      instance.send name
    elsif Workflow.custom_class_exists?("#{name}_decision")
      decide_with_class Workflow.custom_class("#{name}_decision"), instance
    else
      raise Workflow::NoWayToMakeDecision
    end
    
    if value.is_a? TrueClass
      ["yes", "true"]
    elsif value.is_a? FalseClass
      ["no", "false"]
    else
      value
    end
  end
  
  def decide_with_class(clazz, model_instance) #:nodoc:
    decision_instance = clazz.new model_instance
    raise Workflow::CustomDecisionDoesntQuack unless decision_instance.respond_to?(:transition_to_take)
    decision_instance.transition_to_take
  end
end
