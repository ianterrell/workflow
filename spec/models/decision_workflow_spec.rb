require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_decision_workflow(decision_name, yes_transition, no_transition)
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  @decision_node = Factory.create :decision_node, :process => @process, :name => decision_name
  @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @decision_node
  @yes_node = Factory.create :node, :process => @process, :name => "Yes"
  @no_node = Factory.create :node, :process => @process, :name => "No"
  @yes_transition = Factory.create :transition, :name => yes_transition, :from_node => @decision_node, :to_node => @yes_node
  @no_transition = Factory.create :transition, :name => no_transition, :from_node => @decision_node, :to_node => @no_node    
  @model = TestDummy.new
end

def perform_workflow(model)
  model.start_test_workflow
  model.test_workflow.transition! :go
end

describe "A simple workflow with a decision node with yes/no" do
  before do
    create_simple_decision_workflow "grumpy?", "yes", "no"
  end
  
  it "should take the 'yes' transition if true" do
    TestDummy.grumpy = true
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'no' transition if false" do
    TestDummy.grumpy = false
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a decision node with true/false" do
  before do
    create_simple_decision_workflow "grumpy?", "true", "false"
  end
  
  it "should take the 'true' transition if true" do
    TestDummy.grumpy = true
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'false' transition if false" do
    TestDummy.grumpy = false
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a decision node with foo/bar symbols" do
  before do
    create_simple_decision_workflow "grumpy?", "foo", "bar"
  end
  
  it "should take the 'foo' transition if foo" do
    TestDummy.grumpy = :foo
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'bar' transition if bar" do
    TestDummy.grumpy = :bar
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end


describe "A simple workflow with a decision node with foo/bar strings" do
  before do
    create_simple_decision_workflow "grumpy?", "foo", "bar"
  end
  
  it "should take the 'foo' transition if foo" do
    TestDummy.grumpy = "foo"
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'bar' transition if bar" do
    TestDummy.grumpy = "bar"
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a decision node using a class to decide with yes/no" do
  before do
    create_simple_decision_workflow "test", "yes", "no"
  end
  
  it "should take the 'yes' transition if true" do
    TestDecision.value = true
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'no' transition if false" do
    TestDecision.value = false
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a decision node using a class to decide with true/false" do
  before do
    create_simple_decision_workflow "test", "true", "false"
  end
  
  it "should take the 'true' transition if true" do
    TestDecision.value = true
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'false' transition if false" do
    TestDecision.value = false
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a decision node using a class to decide with foo/bar symbols" do
  before do
    create_simple_decision_workflow "test", "foo", "bar"
  end
  
  it "should take the 'foo' transition if foo" do
    TestDecision.value = :foo
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'bar' transition if bar" do
    TestDecision.value = :bar
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end


describe "A simple workflow with a decision node using a class to decide with foo/bar strings" do
  before do
    create_simple_decision_workflow "test", "foo", "bar"
  end
  
  it "should take the 'foo' transition if foo" do
    TestDecision.value = "foo"
    perform_workflow @model
    @model.test_workflow.node.should == @yes_node
  end
  
  it "should take the 'bar' transition if bar" do
    TestDecision.value = "bar"
    perform_workflow @model
    @model.test_workflow.node.should == @no_node
  end
end

describe "A simple workflow with a nonexistent decision method or class" do
  before do
    create_simple_decision_workflow "idontexist_asdfsf", "foo", "bar"
  end
  
  it "should fail with an error" do
    begin
      perform_workflow @model
      fail
    rescue Workflow::NoWayToMakeDecision
    end
  end
end

describe "A simple workflow with a bad custom decision class" do
  before do
    create_simple_decision_workflow "bad_test", "foo", "bar"
  end
  
  it "should fail with an error" do
    begin
      perform_workflow @model
      fail
    rescue Workflow::CustomDecisionDoesntQuack
    end
  end
end