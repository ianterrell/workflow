require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a named decision node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :yes?
          end
          decision :yes? do
            transition :yes, :to => :end
            transition :no, :to => :start
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::DecisionNode.first
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create the decision node" do
    Workflow::DecisionNode.count.should == 1
  end
  
  it "should be named properly" do
    @node.name.should == "yes?"
  end
  
  it "should not have a custom class by default" do
    @node.custom_class.should be_nil
  end
end

describe "Creating a process with a custom class based decision node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :complicated_decision
          end
          decision :complicated_decision, :class_name => "FooBar" do
            transition :yes, :to => :end
            transition :no, :to => :start
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::DecisionNode.first
  end
  
  it "should set the custom class appropriately" do
    @node.custom_class.should == "FooBar"
  end
end

describe "Creating a process with a decision without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end
          end
          decision :class_name => "FooBar" do
            transition :yes, :to => :end
            transition :no, :to => :start
          end
          state :end
        end
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateProcessMigration.up
      fail
    rescue
    end 
  end
end