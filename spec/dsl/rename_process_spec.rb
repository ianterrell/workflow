require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Renaming a process" do
  before do
    Factory.create :process, :name => "Test Workflow"
    class RenameProcessMigration < Workflow::Migration
      def self.up
        rename_process "Test Workflow", "Renamed Workflow"
      end
    end
    RenameProcessMigration.up
  end
  
  it "should rename the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Renamed Workflow"
  end
end