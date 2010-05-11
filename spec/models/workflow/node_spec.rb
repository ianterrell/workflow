require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Node do
  before do
    # Need one in db for validate_uniqueness_of matcher implementation
    @node = Factory.create :node
  end
  
  it "should be valid given valid attributes" do
    Factory(:node).should be_valid
  end
  
  it { should belong_to(:process) }
  it { should have_many(:transitions) }
  it { should have_many(:incoming_transitions) }
  it { should have_many(:process_instance_nodes) }
  it { should have_many(:process_instances) }
  
  it { should validate_presence_of(:name) }
  it "should validate uniqueness of name scoped by the process" do
    node = Workflow::Node.new :process => @node.process, :name => @node.name
    node.should_not be_valid
    node.errors[:name].should include("has already been taken")
    node.process = Factory.create(:process)
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
end