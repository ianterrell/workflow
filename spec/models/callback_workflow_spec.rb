require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "A simple workflow with callbacks" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true, :exit_callbacks => [:foo, :fooz]
    @end_node = Factory.create :node, :process => @process, :name => "End", :enter_callbacks => :bar
    @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @end_node, :callbacks => :baz
    @process.reload.start_node.should == @start_node
    @model = TestDummy.new
  end
    
  it "should call exit callbacks defined on leaving node" do
    @model.should_receive(:foo)
    @model.should_receive(:fooz)    
    perform_workflow @model
  end
  
  it "should call enter callbacks defined on entering node" do
    TestDummy.bar_called = 0
    perform_workflow @model
    TestDummy.bar_called.should == 1
  end
  
  it "should call callbacks defined on transition" do
    @model.should_receive(:baz)
    perform_workflow @model
  end
  
  it "should warn the user for nonexistent callbacks" do
    Rails.logger.should_receive(:warn).at_least(:once)
    perform_workflow @model
  end
  
  def perform_workflow(model)
    model.start_test_workflow
    model.test_workflow.transition! :go
    model.test_workflow.node.should == @end_node    
  end
end