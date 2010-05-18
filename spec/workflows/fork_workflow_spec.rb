require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_fork_workflow(options={})
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  @fork_node = Factory.create :fork_node, :process => @process, :name => "Fork"
  @start_transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @fork_node
  @a_node = Factory.create :node, :process => @process, :name => "Branch A Node"
  @b_node = Factory.create :node, :process => @process, :name => "Branch B Node"
  @fork_transition_a = Factory.create :transition, :name => "a", :from_node => @fork_node, :to_node => @a_node
  @fork_transition_b = Factory.create :transition, :name => "b", :from_node => @fork_node, :to_node => @b_node
  @join_node = Factory.create :join_node, :process => @process, :name => "Join"
  @join_transition_a = Factory.create :transition, :name => "join_a", :from_node => @a_node, :to_node => @join_node
  @join_transition_b = Factory.create :transition, :name => "join_b", :from_node => @b_node, :to_node => @join_node
  @end_node = Factory.create :node, :process => @process, :name => "End"
  @end_transition = Factory.create :transition, :name => "continue", :from_node => @join_node, :to_node => @end_node
  @process.reload.start_node.should == @start_node
  @model = TestDummy.new
end

def perform_fork_workflow
  @model.start_test_workflow
end

describe "A super simple forked workflow" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @fork_node = Factory.create :fork_node, :process => @process, :name => "Fork"
    @start_transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @fork_node
    @join_node = Factory.create :join_node, :process => @process, :name => "Join"
    @fork_transition = Factory.create :transition, :name => "foo", :from_node => @fork_node, :to_node => @join_node
    @end_node = Factory.create :node, :process => @process, :name => "End"
    @end_transition = Factory.create :transition, :name => "continue", :from_node => @join_node, :to_node => @end_node
    @process.reload.start_node.should == @start_node
    @model = TestDummy.new
  end
  
  it "should fork and join itself all the way to the end" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.state.should == @end_node
  end
  
end

describe "A simple forked workflow" do
  before do
    create_simple_fork_workflow
  end
  
  it "should know its current node (which is the same as its state)" do
    perform_fork_workflow
    @model.test_workflow.node.should == @start_node
    @model.test_workflow.state.should == @start_node
  end
  
  it "should have one process instance node when started" do
    Workflow::ProcessInstanceNode.count.should == 0
    perform_fork_workflow
    Workflow::ProcessInstanceNode.count.should == 1
  end
  
  it "should have two process instance nodes after forking" do
    Workflow::ProcessInstanceNode.count.should == 0
    perform_fork_workflow
    Workflow::ProcessInstanceNode.count.should == 1
    @model.test_workflow.transition! :go
    Workflow::ProcessInstanceNode.count.should == 2
  end
  
  it "should know its current nodes plural" do
    perform_fork_workflow
    @model.test_workflow.nodes.should == [@start_node]    
    @model.test_workflow.transition! :go
    @model.test_workflow.nodes.should == [@a_node, @b_node]    
  end
  
  it "should be able to take uniquely named transitions without having to specify a disambiguation" do
    perform_fork_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.transition! "join_a"
    @model.test_workflow.transition! "join_b"
  end
  
  it "should be able to take uniquely named transitions in any order having to specify a disambiguation" do
    perform_fork_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.transition! "join_b"
    @model.test_workflow.transition! "join_a"
  end
  
  it "should continue after joined" do
    perform_fork_workflow
    @model.test_workflow.transition! :go
    @model.test_workflow.transition! "join_b"
    @model.test_workflow.transition! "join_a"
    @model.test_workflow.node.should == @end_node
  end
  
  it "should join up once all the incoming transitions arrive" do
    Workflow::ProcessInstanceNode.count.should == 0
    perform_fork_workflow
    Workflow::ProcessInstanceNode.count.should == 1
    @model.test_workflow.transition! :go
    Workflow::ProcessInstanceNode.count.should == 2
    @model.test_workflow.transition! "join_b"
    Workflow::ProcessInstanceNode.count.should == 2
    @model.test_workflow.transition! "join_a"
    Workflow::ProcessInstanceNode.count.should == 1
  end
end

describe "A forked workflow with an ambiguous transition" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @fork_node = Factory.create :fork_node, :process => @process, :name => "Fork"
    @start_transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @fork_node
    @a_node = Factory.create :node, :process => @process, :name => "node a"
    @b_node = Factory.create :node, :process => @process, :name => "node b"
    @fork_transition_a = Factory.create :transition, :name => "fork_a", :from_node => @fork_node, :to_node => @a_node
    @fork_transition_b = Factory.create :transition, :name => "fork_b", :from_node => @fork_node, :to_node => @b_node
    @join_node = Factory.create :join_node, :process => @process, :name => "Join"
    @join_transition_a = Factory.create :transition, :name => "continue", :from_node => @a_node, :to_node => @join_node
    @join_transition_b = Factory.create :transition, :name => "continue", :from_node => @b_node, :to_node => @join_node
    @end_node = Factory.create :node, :process => @process, :name => "End"
    @end_transition = Factory.create :transition, :name => "continue", :from_node => @join_node, :to_node => @end_node
    @process.reload.start_node.should == @start_node
    @model = TestDummy.new
  end
  
  it "should raise an error unless disambiguated" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    begin
      @model.test_workflow.transition! :continue
      fail
    rescue Workflow::AmbiguousTransition
      $!.message.should == "More than one transition named 'continue' was found."
    end
  end
  
  it "should let you disambiguate with a process instance node" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    node = @model.test_workflow.transition! :continue, @model.test_workflow.process_instance_nodes.for_node(@a_node).first
    node.should == @join_node
    @model.test_workflow.nodes.should == [@join_node, @b_node]
  end
  
  it "should let you disambiguate with a workflow node" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    node = @model.test_workflow.transition! :continue, @a_node
    node.should == @join_node
    @model.test_workflow.nodes.should == [@join_node, @b_node]
  end  
end

describe "A workflow with a bad disambiguation" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @model = TestDummy.new
  end
  
  it "should raise an error" do
    @model.start_test_workflow
    begin
    @model.test_workflow.transition! :go, 1
      fail
    rescue Workflow::NoSuchTransition
      $!.message.should == "Disambiguation passed is not a ProcessInstanceNode that belongs to this ProcessInstance or a Node in this Process (transition named 'go')."
    end
  end
end

describe "A workflow with a disambiguation pin belonging to another instance" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @model = TestDummy.new
    @model2 = TestDummy.new
  end
  
  it "should raise an error" do
    @model.start_test_workflow
    @model2.start_test_workflow
    begin
    @model.test_workflow.transition! :go, @model2.test_workflow.process_instance_nodes.first
      fail
    rescue Workflow::NoSuchTransition
      $!.message.should == "Disambiguation passed is not a ProcessInstanceNode that belongs to this ProcessInstance or a Node in this Process (transition named 'go')."
    end
  end
end

describe "A workflow with a disambiguation node belonging to another process" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @model = TestDummy.new
    @unrelated_node = Factory.create :node
  end
  
  it "should raise an error" do
    @model.start_test_workflow
    begin
    @model.test_workflow.transition! :go, @unrelated_node
      fail
    rescue Workflow::NoSuchTransition
      $!.message.should == "Disambiguation passed is not a ProcessInstanceNode that belongs to this ProcessInstance or a Node in this Process (transition named 'go')."
    end
  end
end

describe "A workflow with a bad transition" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @model = TestDummy.new
  end
  
  it "should raise an error" do
    @model.start_test_workflow
    begin
    @model.test_workflow.transition! "go"
      fail
    rescue Workflow::NoSuchTransition
      $!.message.should == "Could not find a transition named 'go' from current nodes."
    end
  end
end


describe "A forked workflow with tasks in each branch" do
  before do
    @process = Factory.create :process, :name => "Test Workflow"
    @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
    @fork_node = Factory.create :fork_node, :process => @process, :name => "Fork"
    @start_transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @fork_node
    @a_node = Factory.create :task_node, :process => @process, :name => "task a"
    @b_node = Factory.create :task_node, :process => @process, :name => "task b"
    @fork_transition_a = Factory.create :transition, :name => "fork_a", :from_node => @fork_node, :to_node => @a_node
    @fork_transition_b = Factory.create :transition, :name => "fork_b", :from_node => @fork_node, :to_node => @b_node
    @join_node = Factory.create :join_node, :process => @process, :name => "Join"
    @join_transition_a = Factory.create :transition, :name => "completed", :from_node => @a_node, :to_node => @join_node
    @join_transition_b = Factory.create :transition, :name => "completed", :from_node => @b_node, :to_node => @join_node
    @end_node = Factory.create :node, :process => @process, :name => "End"
    @end_transition = Factory.create :transition, :name => "continue", :from_node => @join_node, :to_node => @end_node
    @process.reload.start_node.should == @start_node
    TestDecision.value = true
    @model = TestDummy.new
  end
  
  it "should go along for the ride properly" do
    @model.start_test_workflow
    @model.test_workflow.transition! :go
    Workflow::ProcessInstanceNode.count.should == 2
    Workflow::Task.count.should == 2
    Workflow::Task.all.each do |t|
      t.complete!
    end
    Workflow::ProcessInstanceNode.count.should == 1
    @model.test_workflow.node.should == @end_node
  end
end