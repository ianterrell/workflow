class CreatePublicationProcess < Workflow::ProcessMigration
  def self.up
    create_process "Publication Process" do
      state :submission, :start_state => true, :exit => [:thank_submitter, :notify_staff] do
        transition :done, :to => :copyedit
      end

      task :copyedit, :assign_to => "interns" do
        transition :done, :to => :long_enough?
      end

      decision :long_enough? do
        transition :yes, :to => :proofread
        transition :no, :to => :copyedit
      end

      task :proofread, :enter => :notify_proofreader do
        transition :done, :to => :approval
      end

      state :approval do
        transition :reject, :to => :copyedit
        transition :approve, :to => :published
        timer :send_reminder_email, :repeat => true,
        timer :auto_reject, :after => "10 days"
      end

      state :published
    end
  end
  
  def self.down
    destroy_process "Publication Process"
  end
end