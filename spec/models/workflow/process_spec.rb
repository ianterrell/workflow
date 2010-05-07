require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb')

describe Workflow::Process do
  before do
    # Need one in db for validate_uniqueness_of matcher implementation
    Factory.create :process
  end
  
  it "should be valid given valid attributes" do
    Factory(:process).should be_valid
  end
  
  it { should have_many(:process_instances) }
  it { should have_many(:nodes) }
  
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end