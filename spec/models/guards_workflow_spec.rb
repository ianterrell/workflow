require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_guarded_workflow(options={})
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  @end_node = Factory.create :node, :process => @process, :name => "End"
  if options[:guards]
    @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @end_node, :guards => options[:guards]
  else
    @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @end_node
  end
  @model = TestDummy.new
end

describe "A simple workflow with no guard on transition" do
  before do
    create_simple_guarded_workflow
  end
  
  it "should transition just fine" do
    @model.start_test_workflow
    @model.test_workflow.node.should == @start_node
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @end_node
  end
end

describe "A simple workflow with a single guard" do
  before do
    create_simple_guarded_workflow :guards => "grumpy?"
  end
  
  it "should transition if the guard passes" do
    TestDummy.grumpy = true
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @end_node
  end
  
  it "should not transition if the guard fails" do
    TestDummy.grumpy = false
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @start_node
  end
  
  it "should return false from transition! if the guard fails" do
    TestDummy.grumpy = false
    @model.start_test_workflow
    val = @model.test_workflow.transition! :go
    val.should be_false
  end

  it "should not warn the user" do
    Rails.logger.should_not_receive(:warn)
    @model.start_test_workflow
    @model.test_workflow.transition! :go
  end
end

describe "A simple workflow with a multiple guards" do
  before do
    create_simple_guarded_workflow :guards => ["grumpy?", :always_true?]
  end
  
  it "should transition if the all guards pass" do
    TestDummy.grumpy = true
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @end_node
  end
  
  it "should not transition if any guard fails" do
    TestDummy.grumpy = false
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @start_node
  end
  
  it "should return false from transition! if any guard fails" do
    TestDummy.grumpy = false
    @model.start_test_workflow
    val = @model.test_workflow.transition! :go
    val.should be_false
  end
  
  it "should not warn the user" do
    Rails.logger.should_not_receive(:warn)
    @model.start_test_workflow
    @model.test_workflow.transition! :go
  end
end


describe "A simple workflow with a nonexistent guard" do
  before do
    create_simple_guarded_workflow :guards => "this_is_fake?"
  end
  
  it "should transition as if it passed" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.node.should == @end_node
  end

  it "should warn the user" do
    Rails.logger.should_receive(:warn)
    @model.start_test_workflow
    @model.test_workflow.transition! :go
  end
end

# describe "A simple workflow with an action node using a nonexistent custom action class" do
#   before do
#     create_simple_guarded_workflow :name => "bar", :custom_class => "NonexistentTestAction"
#   end
#   
#   it "should fail with an error" do
#     begin
#       perform_action_workflow
#       fail
#     rescue 
#     end
#   end
# end
# 
# 
# describe "A simple workflow with an action node without any action to perform" do
#   before do
#     create_simple_guarded_workflow :name => "nonexistent_action"
#   end
#   
#   it "should fail with an error" do
#     begin
#       perform_action_workflow
#       fail
#     rescue Workflow::NoWayToPerformAction
#     end
#   end
# end
# 
# describe "A simple workflow with an action node using a nonquacking custom action class" do
#   before do
#     create_simple_guarded_workflow :name => "bar", :custom_class => "BadTestAction"
#   end
#   
#   it "should fail with an error" do
#     begin
#       perform_action_workflow
#       fail
#     rescue Workflow::CustomActionDoesntQuack
#     end
#   end
# end