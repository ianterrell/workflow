require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ProcessInstance do
  it "should be valid given valid attributes" do
    Factory(:process_instance).should be_valid
  end
  
  it { should belong_to(:process) }
  it { should belong_to(:instance) }
  
  it { should have_many(:process_instance_nodes) }
  it { should have_many(:nodes) }
  it { should have_one(:node) }
  it { should respond_to(:state) }
  
  it "should have a scope to find instances by process name" do
    Workflow::ProcessInstance.process_named("asdf").should be_empty
    instance = Factory.create :process_instance, :process => Factory.create(:process, :name => "asdf")
    Workflow::ProcessInstance.process_named("asdf").should include(instance)
    Workflow::ProcessInstance.process_named("jkl").should be_empty
  end
end