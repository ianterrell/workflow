require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Node do
  it "should be valid given valid attributes" do
    Factory(:node).should be_valid
  end
  
  it { should validate_presence_of(:name) }
  it { should belong_to(:process) }
  it { should have_many(:transitions) }
  it { should have_many(:incoming_transitions) }
end