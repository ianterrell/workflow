class Workflow::TaskNode < Workflow::Node
  has_many :tasks, :class_name => "Workflow::Task", :foreign_key => "node_id"
  
  def execute_enter_callbacks(process_instance)
    super
    create_task process_instance
  end
  
protected
  def create_task(process_instance)
    tasks.create :process_instance => process_instance, :assigned_to => assign_to
  end
end
