require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe TestDummy do
  before do
    @process = Factory.create :process, :name => "Sample Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @end_node = Factory.create :node, :process => @process, :name => "End"
    @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @end_node
    @process.reload.start_node.should == @start_node
    @model = TestDummy.new
  end
    
  it "should define a method to start the workflow" do
    @model.should respond_to(:start_sample_workflow)
    Workflow::ProcessInstance.count.should == 0
    @model.start_sample_workflow
    Workflow::ProcessInstance.count.should == 1
  end
  
  it "should know its current process instance for the workflow in the workflow method name" do
    @model.should respond_to(:sample_workflow)
    @model.start_sample_workflow
    @model.sample_workflow.should be_a(Workflow::ProcessInstance)
    @model.sample_workflow.instance.should == @model
    @model.sample_workflow.process.should == @process
  end

  it "should know its current node (which is the same as its state)" do
    @model.start_sample_workflow
    @model.sample_workflow.node.should == @start_node
    @model.sample_workflow.state.should == @start_node
  end
  
  it "should be able to take a transition named by a symbol" do
    @model.start_sample_workflow
    @model.sample_workflow.transition! :go
    @model.sample_workflow.node.should == @end_node
  end
  
  it "should be able to take a transition named by a string" do
    @model.start_sample_workflow
    @model.sample_workflow.transition! "go"
    @model.sample_workflow.state.should == @end_node
  end
end