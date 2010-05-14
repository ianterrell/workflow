require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

# This spec is different from the other decision workflow spec because once upon a time 
# enter callbacks and schedulings were not executed on start states.

describe "A simple workflow with a decision to start" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @decision_node = Factory.create :decision_node, :process => @process, :name => "grumpy?", :start => true
    @yes_node = Factory.create :node, :process => @process, :name => "Yes"
    @no_node = Factory.create :node, :process => @process, :name => "No"
    @yes_transition = Factory.create :transition, :name => "yes", :from_node => @decision_node, :to_node => @yes_node
    @no_transition = Factory.create :transition, :name => "no", :from_node => @decision_node, :to_node => @no_node    
    @model = TestDummy.new
  end
  
  it "should take the 'yes' transition if true" do
    TestDummy.grumpy = true
    @model.start_test_workflow
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'no' transition if false" do
    TestDummy.grumpy = false
    @model.start_test_workflow
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a timer to start" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "start", :start => true
    @end_node = Factory.create :node, :process => @process, :name => "No"
    @transition = Factory.create :transition, :name => "continue", :from_node => @start_node, :to_node => @end_node   
    @timer_generator = Factory.create :scheduled_action_generator, :node => @start_node, :interval => 1.minute, :transition => "continue"
    @model = TestDummy.new
  end
  
  it "should create the timer generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should create the timer on start" do
    Workflow::ScheduledAction.count.should == 0
    Delayed::Job.count.should == 0
    @model.start_test_workflow
    @model.test_workflow.node.should == @start_node
    Workflow::ScheduledAction.count.should == 1
    Delayed::Job.count.should == 1
  end
  
  it "should still work fine" do
    @model.start_test_workflow
    Delayed::Worker.new(:max_priority => nil, :min_priority => nil, :quiet => true).run(Delayed::Job.first)
    @model.reload.test_workflow.node.should == @end_node
  end
end