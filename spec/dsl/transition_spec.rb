require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a transition between states" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 2 # sanity check
  end
  
  it "should create a transition" do
    Workflow::Transition.count.should == 1
  end

  it "should be properly named" do
    Workflow::Transition.first.name.should == "go"
  end
  
  it "should come from the state it was defined in" do
    Workflow::Transition.first.from_node.should == Workflow::Node.find_by_name("start")
  end
  
  it "should go to the state marked in the :to option" do
    Workflow::Transition.first.to_node.should == Workflow::Node.find_by_name("end")
  end
  
  it "should have no callbacks by default" do
    Workflow::Transition.first.callbacks.should be_nil
  end
  
  it "should have no guards by default" do
    Workflow::Transition.first.guards.should be_nil
  end
end

describe "Creating a process with a transition between states with callbacks" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :single, :to => :end, :on_transition => :do_something
            transition :multiple, :to => :end, :on_transition => [:do_something, :do_something_else]
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
  end
  
  it "should create a transition" do
    Workflow::Transition.first.callbacks.should == :do_something
    Workflow::Transition.last.callbacks.should == [:do_something, :do_something_else]
  end
end

describe "Creating a process with a transition between states with guards" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :single, :to => :end, :guard => :something?
            transition :multiple, :to => :end, :guards => [:something?, :something_else?]
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
  end
  
  it "should create a transition" do
    Workflow::Transition.first.guards.should == :something?
    Workflow::Transition.last.guards.should == [:something?, :something_else?]
  end
end

describe "Creating a process with a transition without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :to => :end
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

describe "Creating a process with a transition without a to node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :x => :y
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
      $!.message.should == "The transition 'go' in the node 'start' must have a :to option specifying where it goes."
    end 
  end
end

describe "Creating a process with a transition to a nonexistent node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :vegas_baby
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
      $!.message.should == "The node 'vegas_baby' referenced in the transition 'go' in the node 'start' does not exist in the process 'Test Workflow'."
    end 
  end
end

describe "Creating a process with a transition using :guard and :guards" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end, :guard => :something?, :guards => [:something?, :something_else?]
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
      $!.message.should == "The transition 'go' in the node 'start' may use either :guard for singular or :guards for plural but not both."
    end 
  end
end