class CustomTimerGenerator < Workflow::ScheduledActionGenerator
protected
  def scheduled_time(process_instance)
    (2*interval).from_now
  end
end