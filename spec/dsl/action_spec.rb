require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a named action node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :do_it
          end
          action :do_it do
            transition :completed, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::ActionNode.first
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create the action node" do
    Workflow::ActionNode.count.should == 1
  end
  
  it "should be named properly" do
    @node.name.should == "do_it"
  end
  
  it "should not have a custom class by default" do
    @node.custom_class.should be_nil
  end
end

describe "Creating a process with a custom class based action node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :do_it
          end
          action :do_it, :class_name => "FooBar" do
            transition :completed, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::ActionNode.first
  end
  
  it "should set the custom class appropriately" do
    @node.custom_class.should == "FooBar"
  end
end

describe "Creating a process with an action without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end
          end
          action :class_name => "FooBar" do
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