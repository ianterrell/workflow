require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ActionNode do
  it { should have_many(:actions) }
  
  it "should nullify actions on destruction" do
    action = Factory.create :action
    Workflow::ActionNode.count.should == 1
    Workflow::Action.count.should == 1
    action.node.destroy
    Workflow::ActionNode.count.should == 0
    Workflow::Action.count.should == 1
    action.reload.node.should be_nil
  end
end