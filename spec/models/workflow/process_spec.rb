require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Process do
  it "should be valid given valid attributes" do
    Factory(:process).should be_valid
  end
  
  it { should validate_presence_of(:name) }
  it { should have_many(:process_instances) }
  it { should have_many(:nodes) }
end