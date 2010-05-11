class Workflow::DecisionNode < Workflow::Node
  def execute_enter_callbacks(process_instance)
    super
    transition process_instance
  end
  
protected 
  def transition(process_instance)
    process_instance.transition! transition_to_take(process_instance.instance)
  end

  def transition_to_take(instance)
    value = if !custom_class.blank?
      decide_with_class custom_class.constantize, instance
    elsif instance.respond_to? name
      instance.send name
    elsif decision_instance = Workflow.custom_class_exists?("#{name}_decision")
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
  
  def decide_with_class(clazz, model_instance)
    decision_instance = clazz.new model_instance
    raise Workflow::CustomDecisionDoesntQuack unless decision_instance.respond_to?(:transition_to_take)
    decision_instance.transition_to_take
  end
end
