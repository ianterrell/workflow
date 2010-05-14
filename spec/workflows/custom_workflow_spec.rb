require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_custom_workflow(options={})
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  @custom_node = Factory.create :custom_node, :process => @process, :name => "Do Something Custom"
  @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @custom_node
  @end_node = Factory.create :node, :process => @process, :name => "End"
  @completed_transition = Factory.create :transition, :name => "continue", :from_node => @custom_node, :to_node => @end_node
  @model = TestDummy.new
end

describe "A workflow with a custom provided node" do
  before do
    create_simple_custom_workflow
  end
  
  it "should create the node" do
    @custom_node.should be_a(CustomNode)
  end

  it "should treat it normally" do
    CustomNode.entered_count.should == 0
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @custom_node
    CustomNode.entered_count.should == 1
    @model.test_workflow.transition! :continue
    @model.test_workflow.node.should == @end_node
  end
end