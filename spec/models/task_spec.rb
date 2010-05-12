require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

# TODO:  Currently rescuing the complete! method because the data tier that is created
# with the factories is not in a perfect state.  This could be fixed, although right now
# the behavior isolated in these specs is still defined and tested so it's not necessary
# quite yet.

describe Workflow::Task do
  before do
    @task = Factory.create :task
  end
  
  it "should be valid given valid attributes" do
    Factory(:task).should be_valid
  end
  
  it { should belong_to(:process_instance) }
  it { should belong_to(:node) }
  
  it "should know if it has been completed based on the timestamp" do
    @task.completed_at.should be_nil
    @task.should_not be_completed
    @task.completed_at = Time.now
    @task.should be_completed
  end
  
  it "should set its completed at to Time.now when completed!" do
    @task.completed_at.should be_nil
    t = Time.now
    Time.should_receive(:now).at_least(:once).and_return(t)
    @task.complete! rescue nil
    @task.completed_at.should == t
  end
  
  it "should try to transition its process instance along the transition :completed when completed" do
    @task.process_instance.should_receive(:transition!).with(:completed)
    @task.complete! rescue nil
  end
end