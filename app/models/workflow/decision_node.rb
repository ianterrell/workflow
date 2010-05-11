class Workflow::DecisionNode < Workflow::Node
  def execute_enter_callbacks(process_instance)
    super
    transition process_instance
  end
  
protected 
  def transition_to_take(instance)
    if instance.respond_to? name
      value = instance.send name
      if value.is_a? TrueClass
        ["yes", "true"]
      elsif value.is_a? FalseClass
        ["no", "false"]
      else
        value
      end
    else
      raise "TODO: What's the error case here?"
    end
  end

  def transition(process_instance)
    process_instance.transition! transition_to_take(process_instance.instance)
  end
end
