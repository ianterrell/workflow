class Workflow::ActionNode < Workflow::Node
  has_many :actions, :class_name => "Workflow::Action", :foreign_key => "node_id"

  def execute_enter_callbacks(process_instance)
    super
    create_action process_instance
  end

protected
  def create_action(process_instance)
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