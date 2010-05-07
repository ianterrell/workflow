require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Transition do
  it "should be valid given valid attributes" do
    Factory(:transition).should be_valid
  end
  
  it { should validate_presence_of(:name) }
  it { should belong_to(:from_node) }
  it { should belong_to(:to_node) }
end