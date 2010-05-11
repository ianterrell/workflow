require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Transition do
  before do
    @transition = Factory.create :transition
  end
  
  it "should be valid given valid attributes" do
    Factory(:transition).should be_valid
  end
  
  it { should belong_to(:from_node) }
  it { should belong_to(:to_node) }
  
  it { should validate_presence_of(:name) }
  it "should validate uniqueness of name scoped by its from node" do
    transition = Workflow::Transition.new :from_node => @transition.from_node, :name => @transition.name
    transition.should_not be_valid
    transition.errors[:name].should include("has already been taken")
    transition.from_node = Factory.create(:node)
    transition.should be_valid
  end
  
  it "should have a scope by name" do
    Workflow::Transition.named(@transition.name).should include(@transition)
  end
  
  it "should know its process" do
    @transition.process.should == @transition.from_node.process
  end
  
  it "should serialize callbacks" do
    @transition.callbacks = [:x, :y]
    @transition.save
    Workflow::Transition.find(@transition.id).callbacks.should == [:x, :y]
  end
  
  it "should validate that callbacks are strings, symbols, or arrays of them" do
    @transition.callbacks = :x
    @transition.should be_valid
    @transition.callbacks = "x"
    @transition.should be_valid
    @transition.callbacks = [:x, "y"]
    @transition.should be_valid
    @transition.callbacks = 1
    @transition.should_not be_valid
    @transition.callbacks = [:x, 1]
    @transition.should_not be_valid
  end
end