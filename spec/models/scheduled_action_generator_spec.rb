require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ScheduledActionGenerator do
  before do
    @process_instance = Factory.create :process_instance
    @generator = Factory.create :scheduled_action_generator, :interval => 1.second, :transition => "foo"
  end
  
  it { should belong_to(:node) }
  it { should have_many(:scheduled_actions) }
  
  # TODO:  Validate action or transition?

  it "should generate a scheduled action with a process instance" do
    Workflow::ScheduledAction.count.should == 0
    @generator.generate @process_instance
    Workflow::ScheduledAction.count.should == 1
  end
  
  it "should generate a scheduled action scheduled for Time.now plus the interval" do
    t = Time.now
    Time.should_receive(:now).at_least(:once).and_return(t)
    @generator.generate @process_instance
    Workflow::ScheduledAction.last.scheduled_for.should == t + 1.second
  end
end