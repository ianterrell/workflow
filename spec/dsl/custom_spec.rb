require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a custom node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :app_provided
          end
          custom :app_provided, :node_class => "CustomNode" do
            transition :continue, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create the custom node of the right class" do
    CustomNode.count.should == 1
  end
  
  it "should be named properly" do
    CustomNode.first.name.should == "app_provided"
  end
end


describe "Creating a process with a custom node without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :app_provided
          end
          custom :node_class => "CustomNode" do
            transition :continue, :to => :end
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

describe "Creating a process with a custom node without a custom class" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :app_provided
          end
          custom :app_provided do
            transition :continue, :to => :end
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
    rescue Workflow::Migration::Error
      $!.message.should == "The custom node 'app_provided' must specify its class with :node_class."
    end 
  end
end

describe "Creating a process with a custom node with a custom class that does not descend from Workflow::Node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :app_provided
          end
          custom :app_provided, :node_class => "TestDummy" do
            transition :continue, :to => :end
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
    rescue Workflow::Migration::Error
      $!.message.should == "Custom node classes must descend from Workflow::Node; the class 'TestDummy' in the node 'app_provided' does not."
    end 
  end
end

describe "Creating a process with a custom node with a custom class that does not exist" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :app_provided
          end
          custom :app_provided, :node_class => "WhereAmI" do
            transition :continue, :to => :end
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
    rescue Workflow::Migration::Error
      $!.message.should == "Custom node classes must be defined; the class 'WhereAmI' in the node 'app_provided' can not be found."
    end 
  end
end