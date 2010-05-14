class Workflow::ScheduledActionGenerator < ActiveRecord::Base
  belongs_to :node, :class_name => "Workflow::Node", :foreign_key => "node_id"
  has_many :scheduled_actions, :class_name => "Workflow::ScheduledAction", :foreign_key => "generator_id", :dependent => :destroy
  
  def generate(process_instance)
    clazz = if !custom_class.blank?
      custom_class.constantize
    elsif transition || (action && process_instance.instance.respond_to?(action))
      Workflow::ScheduledAction
    elsif Workflow.custom_class_exists?("#{action}_action")
      Workflow.custom_class("#{action}_action")
    else
      raise Workflow::NoWayToPerformAction
    end
    clazz.create :generator => self, :node => node, :process_instance => process_instance, :scheduled_for => self.scheduled_time(process_instance)
  end
  
protected
  def scheduled_time(process_instance)
    interval.from_now
  end
end
