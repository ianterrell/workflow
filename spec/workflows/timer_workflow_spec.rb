# Things to spec:

# state :approval do
#   transition :approved, :to => :published
#   transition :rejected, :to => :start
#   timer :take_transition => :rejected, :after => 3.days
#   timer :perform => :callback, :after => 5.minutes
# end
# 
# wait_state :holding_pattern, :transition_to => :xyz, :after => 5.days
# 
# state :holding_pattern do
#   transition :name, :to => :xyz
#   timer :transition => :name, :after => 5.days
# end

# Timer to perform an action on the model repeatedly
# Timer to perform an action on the model repeatedly up to X times
# Timer to perform an action via a custom class, & repeatedly, & up to X times

# Subclass timer generator class

require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_timer_workflow(options={})
  options.reverse_merge!({ :interval => 1.second })
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  @timer_node = Factory.create :node, :process => @process, :name => "Timer Node"
  if options[:transition]
    @timer_generator = Factory.create :scheduled_action_generator, :node => @timer_node, :interval => options[:interval], :transition => options[:transition]
  else
    @timer_generator = Factory.create :scheduled_action_generator, :node => @timer_node, :interval => options[:interval], :action => "bar"
  end
  @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @timer_node
  @end_node = Factory.create :node, :process => @process, :name => "End"
  @finish_transition = Factory.create :transition, :name => "finish", :from_node => @timer_node, :to_node => @end_node
  @model = TestDummy.new
  @worker = Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true)    
end

def perform_timer_workflow
  @model.start_test_workflow
  @model.test_workflow.transition! :go
end

describe "A simple workflow with a timer" do
  before do
    create_simple_timer_workflow
  end
  
  it "should create a timer on entry" do
    Workflow::ScheduledAction.count.should == 0
    Delayed::Job.count.should == 0
    perform_timer_workflow
    @model.test_workflow.node.should == @timer_node
    Workflow::ScheduledAction.count.should == 1
    Delayed::Job.count.should == 1
  end
  
  it "should create a task linked to this process instance" do
    perform_timer_workflow
    Workflow::ScheduledAction.last.process_instance.should == @model.test_workflow
  end
 
  it "should create a task linked to the node that created it" do
    perform_timer_workflow
    Workflow::ScheduledAction.last.node.should == @timer_node
  end
    
  it "should create a task scheduled for now plus the interval" do
    t = Time.now
    Time.should_receive(:now).at_least(:once).and_return(t)
    perform_timer_workflow
    Workflow::ScheduledAction.last.scheduled_for.should == t + 1.second
  end
  
  it "should cancel the task if it hasn't occurred when transitioned out" do
    perform_timer_workflow
    Workflow::ScheduledAction.last.should_not be_canceled
    Delayed::Job.count.should == 1
    @model.test_workflow.transition! :finish
    Workflow::ScheduledAction.last.should be_canceled
    Delayed::Job.count.should == 0
  end
end

describe "A simple workflow with a timer action" do
  before do
    create_simple_timer_workflow
  end
  
  it "should perform the action on the model" do
    TestDummy.bar_called = 0
    Delayed::Job.count.should == 0

    perform_timer_workflow
    Delayed::Job.count.should == 1
    TestDummy.bar_called.should == 0
    
    @worker.run(Delayed::Job.first)
    TestDummy.bar_called.should == 1
    Delayed::Job.count.should == 0
    Workflow::ScheduledAction.last.should_not be_canceled
    
    @model.reload.test_workflow.node.should == @timer_node
  end
  
  it "should not perform the action if the task was canceled" do
    TestDummy.bar_called = 0
    perform_timer_workflow
    @model.test_workflow.transition! :finish
    Workflow::ScheduledAction.last.should be_canceled
    TestDummy.bar_called.should == 0
    Delayed::Job.count.should == 0
  end
end

describe "A simple workflow with a timer based transition" do
  before do
    create_simple_timer_workflow :transition => "finish"
  end
  
  it "should execute the transition" do
    perform_timer_workflow
    @worker.run(Delayed::Job.first)
    @model.reload.test_workflow.node.should == @end_node
  end
end
