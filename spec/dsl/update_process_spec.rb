require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Updating a process" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
        end
      end
    end
    CreateProcessMigration.up
    class ProcessMigration < Workflow::Migration
      def self.up
        update_process "Test Workflow"
      end
    end
  end
  
  it "should not fail" do
    ProcessMigration.up
  end
end

describe "Adding a state to a process" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
        end
      end
    end
    CreateProcessMigration.up
    class ProcessMigration < Workflow::Migration
      def self.up
        update_process "Test Workflow" do
          state :end
        end
      end
    end
    ProcessMigration.up
  end
  
  it "should create the state" do
    Workflow::Node.count.should == 2
  end
end