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
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create a start state" do
    Workflow::Node.count.should == 1
    node = Workflow::Node.first
    node.name.should == "test_state"
    node.process.name.should == "Test Workflow"
    node.should be_start
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
    rescue Workflow::Migration::StateMustBeWithinProcess
    end 
  end
end
