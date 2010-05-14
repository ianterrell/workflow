require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a named task node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :do_it
          end
          task :do_it do
            transition :completed, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::TaskNode.first
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create the task node" do
    Workflow::TaskNode.count.should == 1
  end
  
  it "should be named properly" do
    @node.name.should == "do_it"
  end
  
  it "should not have any assign to by default" do
    @node.assign_to.should be_nil
  end
  
  it "should not have a custom class by default" do
    @node.custom_class.should be_nil
  end
end

describe "Creating a process with a task node with assignment" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :do_it
          end
          task :do_it, :assign_to => "jeff" do
            transition :completed, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::TaskNode.first
  end
  
  it "should set the assign_to appropriately" do
    @node.assign_to.should == "jeff"
  end
end

describe "Creating a process with a custom class based task node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :do_it
          end
          task :do_it, :task_class => "FooBar" do
            transition :completed, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::TaskNode.first
  end
  
  it "should set the custom class appropriately" do
    @node.custom_class.should == "FooBar"
  end
end

describe "Creating a process with a task without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end
          end
          task :task_class => "FooBar" do
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