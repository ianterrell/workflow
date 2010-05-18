require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Renaming a node" do
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
          rename_node :start, :new_start
        end
      end
    end
    ProcessMigration.up
  end
  
  it "should not create a new process" do
    Workflow::Process.count.should == 1
  end
  
  it "should rename the node" do
    Workflow::Node.count.should == 1
    Workflow::Node.first.name.should == "new_start"
  end
end

describe "Renaming a node outside of a process" do
  before do
    class RenameNodeOutsideProcessMigration < Workflow::Migration
      def self.up
        rename_node :start, :new_start
      end
    end
  end
  
  it "should raise an error" do
    begin
      RenameNodeOutsideProcessMigration.up
      fail
    rescue Workflow::Migration::Error
      $!.message.should == "Renaming nodes ('start' => 'new_start') must occur in an update_process call."
    end
  end
end


describe "Renaming a node inside a create process migration" do
  before do
    class RenameNodeInsideCreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true
          rename_node :start, :new_start
        end
      end
    end
  end
  
  it "should raise an error" do
    begin
      RenameNodeInsideCreateProcessMigration.up
      fail
    rescue Workflow::Migration::Error
      $!.message.should == "Renaming nodes ('start' => 'new_start') must occur in an update_process call."
    end
  end
end