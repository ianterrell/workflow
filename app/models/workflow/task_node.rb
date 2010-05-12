class Workflow::TaskNode < Workflow::Node
  has_many :tasks, :class_name => "Workflow::Task", :foreign_key => "node_id"
  
  def execute_enter_callbacks(process_instance)
    super
    
    # As an important implementation detail, this method returns the task created, which ActionNode and 
    # other subclasses can use to execute it automatically
    create_task process_instance
  end
  
protected
  def create_task(process_instance)
    clazz = if custom_class.blank?
      default_task_class
    else
      custom_class.constantize rescue raise Workflow::BadTaskClass
    end
    clazz.create :node => self, :process_instance => process_instance, :assigned_to => assign_to
  end
  
  def default_task_class
    Workflow::Task
  end
end
