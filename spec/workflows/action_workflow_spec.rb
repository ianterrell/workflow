require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_action_workflow(options={})
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  if options[:custom_class]
    @action_node = Factory.create :action_node, :process => @process, :name => options[:name], :custom_class => options[:custom_class]
  else
    @action_node = Factory.create :action_node, :process => @process, :name => options[:name]
  end
  @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @action_node
  @end_node = Factory.create :node, :process => @process, :name => "End"
  @completed_transition = Factory.create :transition, :name => "completed", :from_node => @action_node, :to_node => @end_node
  @model = TestDummy.new
end

def perform_action_workflow
  @model.start_test_workflow
  @model.test_workflow.transition! :go
end

describe "A simple workflow with an action node" do
  before do
    create_simple_action_workflow :name => "bar"
  end
  
  it "should create an action on entry" do
    Workflow::Action.count.should == 0
    perform_action_workflow
    Workflow::Action.count.should == 1
  end
  
  it "should create an action linked to this process instance" do
    perform_action_workflow
    Workflow::Action.last.process_instance.should == @model.test_workflow
  end
  
  it "should create an action linked to the action node that created it" do
    perform_action_workflow
    Workflow::Action.last.node.should == @action_node
  end
  
  it "should automatically complete the action by calling bar on the model" do
    TestDummy.bar_called = 0
    perform_action_workflow
    TestDummy.bar_called.should == 1
    @model.reload.test_workflow.node.should == @end_node
  end
end

describe "A simple workflow with an action node using a custom action class" do
  before do
    create_simple_action_workflow :name => "bar", :custom_class => "TestAction"
  end
  
  it "should create a custom action instance on entry" do
    TestAction.count.should == 0
    perform_action_workflow
    TestAction.count.should == 1
  end
  
  it "should perform the custom action's perform method" do
    TestAction.perform_count = 0
    perform_action_workflow
    TestAction.perform_count.should == 1
  end
end

describe "A simple workflow with an action node using a nonexistent custom action class" do
  before do
    create_simple_action_workflow :name => "bar", :custom_class => "NonexistentTestAction"
  end
  
  it "should fail with an error" do
    begin
      perform_action_workflow
      fail
    rescue 
    end
  end
end


describe "A simple workflow with an action node without any action to perform" do
  before do
    create_simple_action_workflow :name => "nonexistent_action"
  end
  
  it "should fail with an error" do
    begin
      perform_action_workflow
      fail
    rescue Workflow::NoWayToPerformAction
    end
  end
end

describe "A simple workflow with an action node using a nonquacking custom action class" do
  before do
    create_simple_action_workflow :name => "bar", :custom_class => "BadTestAction"
  end
  
  it "should fail with an error" do
    begin
      perform_action_workflow
      fail
    rescue Workflow::CustomActionDoesntQuack
    end
  end
end