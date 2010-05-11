class Workflow::DecisionNode < Workflow::Node
  def execute_enter_callbacks(process_instance)
    super
    transition process_instance
  end
  
protected 
  def transition_to_take(instance)
    value = if instance.respond_to? name
      instance.send name
    elsif class_exists?("#{name}_decision".camelize)
      decision_instance = "#{name}_decision".camelize.constantize.new
      raise Workflow::CustomDecisionDoesntQuack unless decision_instance.respond_to?(:transition_to_take)
      decision_instance.transition_to_take
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

  def transition(process_instance)
    process_instance.transition! transition_to_take(process_instance.instance)
  end
  
  def class_exists?(clazz_string)
    begin
      clazz_string.constantize
      true
    rescue
      false
    end
  end
end
