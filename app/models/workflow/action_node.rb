class Workflow::ActionNode < Workflow::TaskNode
  has_many :actions, :class_name => "Workflow::Action", :foreign_key => "node_id"

  def execute_enter_callbacks(process_instance)
    perform_action super
  end
  
protected
  def default_task_class
    Workflow::Action
  end
  
  def perform_action(action)
    action.process_instance.instance.send name
    action.complete!
  end
end