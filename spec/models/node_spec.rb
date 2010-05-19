require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::Node do
  before do
    # Need one in db for validate_uniqueness_of matcher implementation
    @node = Factory.create :node
    @node2 = Factory.create :node, :process => @node.process
  end
  
  it "should be valid given valid attributes" do
    Factory(:node).should be_valid
  end
  
  it { should belong_to(:process) }
  it { should have_many(:transitions) }
  it { should have_many(:incoming_transitions) }
  it { should have_many(:process_instance_nodes) }
  it { should have_many(:process_instances) }
  
  it { should have_many(:scheduled_action_generators) }
  it { should have_many(:scheduled_actions) }
  
  it { should validate_presence_of(:name) }
  it "should validate uniqueness of name scoped by the process" do
    node = Workflow::Node.new :process => @node.process, :name => @node.name
    node.should_not be_valid
    node.errors[:name].should include("has already been taken")
    node.process = Factory.create(:process)
    node.should be_valid
  end
  
  it "should validate that it is the only start state in the process" do
    @node.update_attribute :start, true
    node = Workflow::Node.new :process => @node.process, :name => @node.name + " start", :start => true
    node.should_not be_valid
    node.errors[:base].should include("Process already has a start node.")
    node.start = false
    node.should be_valid
  end
  
  it "should serialize enter callbacks" do
    @node.enter_callbacks = [:x, :y]
    @node.save
    Workflow::Node.find(@node.id).enter_callbacks.should == [:x, :y]
  end
  
  it "should serialize exit callbacks" do
    @node.exit_callbacks = [:x, :y]
    @node.save
    Workflow::Node.find(@node.id).exit_callbacks.should == [:x, :y]
  end
  
  it "should validate that enter callbacks are strings, symbols, or arrays of them" do
    @node.enter_callbacks = :x
    @node.should be_valid
    @node.enter_callbacks = "x"
    @node.should be_valid
    @node.enter_callbacks = [:x, "y"]
    @node.should be_valid
    @node.enter_callbacks = 1
    @node.should_not be_valid
    @node.enter_callbacks = [:x, 1]
    @node.should_not be_valid
  end
  
  it "should validate that exit callbacks are strings, symbols, or arrays of them" do
    @node.exit_callbacks = :x
    @node.should be_valid
    @node.exit_callbacks = "x"
    @node.should be_valid
    @node.exit_callbacks = [:x, "y"]
    @node.should be_valid
    @node.exit_callbacks = 1
    @node.should_not be_valid
    @node.exit_callbacks = [:x, 1]
    @node.should_not be_valid
  end
  
  it "should destroy outgoing transitions on destruction" do
    Factory.create :transition, :from_node => @node, :to_node => @node2
    Workflow::Transition.count.should == 1
    @node.destroy
    Workflow::Transition.count.should == 0
  end
  
  it "should destroy incoming transitions on destruction" do
    Factory.create :transition, :from_node => @node, :to_node => @node2
    Workflow::Transition.count.should == 1
    @node2.destroy
    Workflow::Transition.count.should == 0
  end
  
  it "should destroy timer generators on destruction" do
    Factory.create :scheduled_action_generator, :node => @node
    Workflow::ScheduledActionGenerator.count.should == 1
    @node.destroy
    Workflow::ScheduledActionGenerator.count.should == 0
  end
  
  it "should destroy timers on destruction" do
    generator = Factory.create :scheduled_action_generator, :node => @node
    Factory.create :scheduled_action, :generator => generator
    Workflow::ScheduledAction.count.should == 1
    @node.destroy
    Workflow::ScheduledAction.count.should == 0
  end
  
  it "should destroy process instances nodes on destruction" do
    Factory.create :process_instance_node, :node => @node
    Workflow::ProcessInstanceNode.count.should == 1
    @node.destroy
    Workflow::ProcessInstanceNode.count.should == 0
  end
  
  it "should have a scope by name" do
    Workflow::Node.named(@node.name).should include(@node)
  end
  
  it "should be extensible by the host application" do
    Workflow::Node.new.should respond_to(:host_app_provided_method)
  end
end