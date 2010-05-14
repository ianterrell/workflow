require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a start state" do
  before do
    class CreateProcessWithStateMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :test_state, :start_state => true
        end
      end
    end
    CreateProcessWithStateMigration.up
    @node = Workflow::Node.first
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create a start state" do
    Workflow::Node.count.should == 1
    @node.name.should == "test_state"
    @node.process.name.should == "Test Workflow"
    @node.should be_start
  end
  
  it "should have no callbacks by default" do
    @node.enter_callbacks.should be_nil
    @node.exit_callbacks.should be_nil
  end
end

describe "Creating states with callbacks" do
  before do
    class CreateProcessWithStateMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
          state :enter_single, :enter => :do_something
          state :enter_multiple, :enter => [:do_something, :do_something_else]
          state :exit_single, :exit => :do_something
          state :exit_multiple, :exit => [:do_something, :do_something_else]
        end
      end
    end
    CreateProcessWithStateMigration.up
    @node = Workflow::Node.first
  end
  
  it "should create single enter callbacks" do
    Workflow::Node.named("enter_single").first.enter_callbacks.should == :do_something
  end
  
  it "should create multiple enter callbacks" do
    Workflow::Node.named("enter_multiple").first.enter_callbacks.should == [:do_something, :do_something_else]
  end
  
  it "should create single exit callbacks" do
    Workflow::Node.named("exit_single").first.exit_callbacks.should == :do_something
  end
  
  it "should create multiple exit callbacks" do
    Workflow::Node.named("exit_multiple").first.exit_callbacks.should == [:do_something, :do_something_else]
  end
end

describe "Creating a process with two start states" do
  before do
    class CreateProcessWithTwoStartStatesMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :test_state, :start_state => true
          state :test_state_beta, :start_state => true
        end
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateProcessWithTwoStartStatesMigration.up
      fail
    rescue ActiveRecord::RecordInvalid
      $!.message.should =~ /already has a start node/
    end 
  end
end

describe "Creating a state without a process" do
  before do
    class CreateStateWithoutProcessMigration < Workflow::Migration
      def self.up
        state :test_state
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateStateWithoutProcessMigration.up
      fail
    rescue Workflow::Migration::Error
      $!.message.should == "The node 'test_state' must be defined within a process."
    end 
  end
end

describe "Creating a state without a name" do
  before do
    class CreateStateWithoutProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state
        end
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateStateWithoutProcessMigration.up
      fail
    rescue
    end 
  end
end
