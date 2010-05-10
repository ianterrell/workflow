require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Process do
  before do
    # Need one in db for validate_uniqueness_of matcher implementation
    @process = Factory.create :process
  end
  
  it "should be valid given valid attributes" do
    Factory(:process).should be_valid
  end
  
  it { should have_many(:process_instances) }
  it { should have_many(:nodes) }
  it { should have_one(:start_node) }
  
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  
  it "should have the start node be the one with the start flag marked" do
    @process.start_node.should be_nil
    node = Factory.create :node, :process => @process
    @process.reload.start_node.should be_nil
    node.update_attribute :start, true
    @process.reload.start_node.should == node
  end
  
  it "should have a scope by name" do
    Workflow::Process.named(@process.name).should include(@process)
  end
end