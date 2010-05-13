class TimerTestAction < Workflow::ScheduledAction
  cattr_accessor :perform_count
  
  def perform
    @@perform_count ||= 0
    @@perform_count += 1
  end
end