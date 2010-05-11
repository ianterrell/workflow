require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "A simple two state workflow" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @end_node = Factory.create :node, :process => @process, :name => "End"
    @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @end_node
    @process.reload.start_node.should == @start_node
    @model = TestDummy.new
  end
    
  it "should define a method to start the workflow" do
    @model.should respond_to(:start_test_workflow)
    Workflow::ProcessInstance.count.should == 0
    @model.start_test_workflow
    Workflow::ProcessInstance.count.should == 1
  end
  
  it "should know its current process instance for the workflow in the workflow method name" do
    @model.should respond_to(:test_workflow)
    @model.start_test_workflow
    @model.test_workflow.should be_a(Workflow::ProcessInstance)
    @model.test_workflow.instance.should == @model
    @model.test_workflow.process.should == @process
  end

  it "should know its current node (which is the same as its state)" do
    @model.start_test_workflow
    @model.test_workflow.node.should == @start_node
    @model.test_workflow.state.should == @start_node
  end
  
  it "should be able to take a transition named by a symbol" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @end_node
  end
  
  it "should be able to take a transition named by a string" do
    @model.start_test_workflow
    @model.test_workflow.transition! "go"
    @model.test_workflow.state.should == @end_node
  end
end