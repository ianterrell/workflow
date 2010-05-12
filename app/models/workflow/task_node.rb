class Workflow::TaskNode < Workflow::Node
  has_many :tasks, :class_name => "Workflow::Task", :foreign_key => "node_id"
  
  def execute_enter_callbacks(process_instance)
    super
    create_task process_instance
  end
  
protected
  def create_task(process_instance)
    clazz = if custom_class.blank?
      Workflow::Task
    else
      custom_class.constantize rescue raise Workflow::BadTaskClass
    end
    clazz.create :node => self, :process_instance => process_instance, :assigned_to => assign_to
  end
end
