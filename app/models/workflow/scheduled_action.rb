class Workflow::ScheduledAction < Workflow::Action
  belongs_to :generator, :class_name => "Workflow::ScheduledActionGenerator", :foreign_key => "generator_id"
  belongs_to :delayed_job, :class_name => "::Delayed::Job", :foreign_key => "delayed_job_id"
  
  validates_presence_of :scheduled_for
  
  def perform
    if generator.transition.blank?
      process_instance.instance.send generator.action
      schedule_repeat
    else
      process_instance.transition! generator.transition 
    end
  end
  
  def scheduled?
    !!scheduled_for
  end
  
  def canceled?
    !!canceled_at
  end
  
  def cancel!
    update_attribute :canceled_at, Time.now
    delayed_job.destroy if delayed_job
  end
  
  after_create :create_delayed_job
  
protected
  def create_delayed_job
    job = Delayed::Job.enqueue self, 0, scheduled_for
    self.update_attribute :delayed_job_id, job.id
  end
  
  def schedule_repeat
    if generator.repeat?
      unless generator.repeat_count && Workflow::ScheduledAction.where(:generator_id => generator.id).where(:process_instance_id => process_instance.id).count >= generator.repeat_count
        generator.generate process_instance
      end
    end
  end
end