require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ScheduledAction do
  before do
    @action = Factory.create :scheduled_action
  end
  
  it "should be valid given valid attributes" do
    Factory(:scheduled_action).should be_valid
  end
  
  it { should belong_to(:process_instance) }
  it { should belong_to(:node) }
  it { should belong_to(:generator) }
  it { should belong_to(:delayed_job) }
  
  it { should validate_presence_of(:scheduled_for) }

  it "should know if it has been scheduled based on the timestamp" do
    @action.scheduled_for = nil
    @action.should_not be_scheduled
    @action.scheduled_for = Time.now
    @action.should be_scheduled
  end

  it "should know if it has been canceled based on the timestamp" do
    @action.canceled_at.should be_nil
    @action.should_not be_canceled
    @action.canceled_at = Time.now
    @action.should be_canceled
  end

  it "should know if it has been completed based on the timestamp" do
    @action.completed_at.should be_nil
    @action.should_not be_completed
    @action.completed_at = Time.now
    @action.should be_completed
  end
  
  it "should cancel itself" do
    @action.should_not be_canceled
    @action.cancel!
    @action.should be_canceled
    # Delayed job bit handled in workflow specs
  end

  # it "should set its completed at to Time.now when completed!" do
  #   @action.completed_at.should be_nil
  #   t = Time.now
  #   Time.should_receive(:now).at_least(:once).and_return(t)
  #   @action.complete! rescue nil
  #   @action.completed_at.should == t
  # end
  # 
  # it "should not try to transition its process when performed" do
  #   @action.process_instance.should_receive(:transition!).with(:completed)
  #   @action.complete! rescue nil
  # end
end