# This is the default implementation of an automatically executed Action that happens at a certain time.  There
# are two types of scheduled actions supported by this model:  taking a transition and performing an action
# on the model.  If the generator's 'transition' field is set, it does the former; if not, the latter.
# 
# It is necessary for another process to periodically poll the database to execute actions
# on time.  If config.workflow.timer_engine is :delayed_job this class will automatically manage
# a Delayed::Job based implementation for you, although you still must run the worker.
class Workflow::ScheduledAction < Workflow::Action
  belongs_to :generator, :class_name => "Workflow::ScheduledActionGenerator", :foreign_key => "generator_id"
  
  validates_presence_of :scheduled_for
  
  # If the generator's 'transition' field is not blank, it attempts to take the transition.
  # If it is blank, it attempts to execute the action specified by the generator on the model instance,
  # and then schedule a repeat action if the generator specifies it.
  def perform
    if generator.transition.blank?
      process_instance.instance.send generator.action
      schedule_repeat
    else
      process_instance.transition! generator.transition, generator.node
    end
  end
  
  # Returns true if this action has been scheduled (time lives in scheduled_for)
  def scheduled?
    !!scheduled_for
  end
  
  # Returns true if this action has been canceled (time lives in canceled_at)
  def canceled?
    !!canceled_at
  end
  
  # Cancels this action.  It sets the canceled_at timestamp and destroys the associated Delayed::Job.
  def cancel!
    update_attribute :canceled_at, Time.now
    delayed_job.destroy if Rails.application && (Rails.application.config.workflow.timer_engine == :delayed_job) && delayed_job
  end
  
  ###
  # Delayed Job implementation
  
  if Rails.application.config.workflow.timer_engine == :delayed_job
    belongs_to :delayed_job, :class_name => "::Delayed::Job", :foreign_key => "delayed_job_id", :dependent => :destroy
    after_create :create_delayed_job
  
    def create_delayed_job #:nodoc:
      job = Delayed::Job.enqueue self, 0, scheduled_for
      self.update_attribute :delayed_job_id, job.id
    end
  end
  
protected
  def schedule_repeat #:nodoc:
    if generator.repeat?
      unless generator.repeat_count && Workflow::ScheduledAction.where(:generator_id => generator.id).where(:process_instance_id => process_instance.id).count >= generator.repeat_count
        generator.generate process_instance
      end
    end
  end
end