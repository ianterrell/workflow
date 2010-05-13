require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::TaskNode do
  it { should have_many(:tasks) }
  
  it "should nullify tasks on destruction" do
    task = Factory.create :task
    Workflow::TaskNode.count.should == 1
    Workflow::Task.count.should == 1
    task.node.destroy
    Workflow::TaskNode.count.should == 0
    Workflow::Task.count.should == 1
    task.reload.node.should be_nil
  end
end