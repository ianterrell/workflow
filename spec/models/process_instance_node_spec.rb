require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ProcessInstanceNode do
  it "should be valid given valid attributes" do
    Factory(:process_instance_node).should be_valid
  end
  
  it { should belong_to(:process_instance) }
  it { should belong_to(:node) }
  it { should have_many(:transitions) }
  
  it "should be able to find instances based on a node" do
    @node = Factory.create :node
    Workflow::ProcessInstanceNode.for_node(@node).should be_empty
    @pin = Factory.create :process_instance_node, :node => @node
    Workflow::ProcessInstanceNode.for_node(@node).should include(@pin)
  end
  
  it "should be able to find instances based on a process instance" do
    @instance = Factory.create :process_instance
    Workflow::ProcessInstanceNode.for_instance(@instance).should be_empty
    @pin = Factory.create :process_instance_node, :process_instance => @instance
    Workflow::ProcessInstanceNode.for_instance(@instance).should include(@pin)
  end
  
  it "should be able to find instances based on a transition name" do
    @node = Factory.create :node
    @transition = Factory.create :transition, :name => "foo", :from_node => @node
    Workflow::ProcessInstanceNode.with_transition_named("foo").should be_empty
    @pin = Factory.create :process_instance_node, :node => @node
    @pin.transitions.should include(@transition)
    Workflow::ProcessInstanceNode.with_transition_named("foo").should include(@pin)
  end
end