require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::ProcessInstanceNode do
  it "should be valid given valid attributes" do
    Factory(:process_instance_node).should be_valid
  end
  
  it { should belong_to(:process_instance) }
  it { should belong_to(:node) }
end