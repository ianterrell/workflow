require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::ProcessInstance do
  it "should be valid given valid attributes" do
    Factory(:process_instance).should be_valid
  end
  
  it { should belong_to(:process) }
  it { should belong_to(:instance) }
  
  it { should have_many(:process_instance_nodes) }
  it { should have_many(:nodes) }
end