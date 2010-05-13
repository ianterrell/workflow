require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
        end
      end
    end
    CreateProcessMigration.up
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
end

describe "Destroying a process" do
  before do
    class DestroyProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
        end
        create_process "Test Workflow Beta" do
          state :start, :start_state => true
        end
      end
      def self.down
        destroy_process "Test Workflow"
      end
    end
    DestroyProcessMigration.up
  end
  
  it "should destroy the named process and its states" do
    Workflow::Process.count.should == 2
    Workflow::Node.count.should == 2
    DestroyProcessMigration.down
    Workflow::Process.count.should == 1
    Workflow::Node.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow Beta"
  end
end

# TODO:  How to test transaction in migration without turning off transactionality
# for all of the spec suite?

describe "Creating a process without a start state explicitly defined" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start
        end
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateProcessMigration.up
      fail
    rescue Workflow::Migration::ProcessMustHaveStartState
    end
  end
end

describe "Creating a process without any state" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow"
      end
    end
  end
  
  it "should raise an exception" do
    begin
      CreateProcessMigration.up
      fail
    rescue Workflow::Migration::ProcessMustHaveStartState
    end 
  end
end