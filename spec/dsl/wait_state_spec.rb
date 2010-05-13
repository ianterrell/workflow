require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a simple transition based timer" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :holding_pattern
          end
          wait_state :holding_pattern, :transition_to => :end, :after => 7.days
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 3 # sanity check
    @generator = Workflow::ScheduledActionGenerator.first
  end

  it "should create the state" do
    Workflow::Node.named("holding_pattern").count.should == 1
  end
  
  it "should create a transition named 'continue' that goes to :transition_to in that node" do
    transition = Workflow::Node.named("holding_pattern").first.transitions.first
    transition.name.should == "continue"
    transition.to_node.should == Workflow::Node.named("end").first
  end
  
  it "should create a scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should be attached to the node" do
    @generator.node.should == Workflow::Node.named("holding_pattern").first
  end
  
  it "should have the appropriate interval" do
    @generator.interval.should == 1.week
  end
  
  it "should have no action" do
    @generator.action.should be_nil
  end
  
  it "should have the transition set to 'continue'" do
    @generator.transition.should == "continue"
  end
  
  it "should not repeat" do
    @generator.repeat?.should be_false
    @generator.repeat_count.should be_nil
  end
end

describe "Creating a process with a simple transition based timer without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :end
          end
          wait_state :transition_to => :end, :after => 7.days
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

describe "Creating a process with a simple transition based timer without options" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :holding_pattern
          end
          wait_state :holding_pattern
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

describe "Creating a process with a simple transition based timer without a transition_to" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :holding_pattern
          end
          wait_state :holding_pattern, :after => 7.days
          state :end
        end
      end
    end
  end
  it "should raise an exception" do
    begin
      CreateProcessMigration.up
      fail
    rescue Workflow::Migration::WaitStateNeedsTransitionTo
      $!.message.should == "The wait state 'holding_pattern' in the process 'Test Workflow' needs to specify a node to transition to with :transition_to."
    end 
  end
end

describe "Creating a process with a simple transition based timer without an interval" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :holding_pattern
          end
          wait_state :holding_pattern, :transition_to => :end
          state :end
        end
      end
    end
  end
  it "should raise an exception" do
    begin
      CreateProcessMigration.up
      fail
    rescue Workflow::Migration::WaitStateNeedsInterval
      $!.message.should == "The wait state 'holding_pattern' in the process 'Test Workflow' needs to specify an interval to wait with :after."
    end 
  end
end