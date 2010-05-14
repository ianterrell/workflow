require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a simple action based timer" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :after => 3.minutes
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 3 # sanity check
    @generator = Workflow::ScheduledActionGenerator.first
  end
  
  it "should create a scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should be attached to the node" do
    @generator.node.should == Workflow::Node.named("timed_state").first
  end
  
  it "should have the appropriate interval" do
    @generator.interval.should == 3.minutes
  end
  
  it "should have the action set" do
    @generator.action.should == "do_something"
  end
  
  it "should have no transition" do
    @generator.transition.should be_nil
  end
  
  it "should not repeat" do
    @generator.repeat?.should be_false
    @generator.repeat_count.should be_nil
  end
end

describe "Creating a process with an infinitely repeating action based timer" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :every => 3.minutes
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 3 # sanity check
    @generator = Workflow::ScheduledActionGenerator.first
  end
  
  it "should create a scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should be attached to the node" do
    @generator.node.should == Workflow::Node.named("timed_state").first
  end
  
  it "should have the appropriate interval" do
    @generator.interval.should == 3.minutes
  end
  
  it "should have the action set" do
    @generator.action.should == "do_something"
  end
  
  it "should have no transition" do
    @generator.transition.should be_nil
  end
  
  it "should repeat" do
    @generator.repeat?.should be_true
  end
  
  it "should repeat indefinitely" do
    @generator.repeat_count.should be_nil
  end
end


describe "Creating a process with an limited repeating action based timer" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :every => 3.minutes, :up_to => 3.times
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 3 # sanity check
    @generator = Workflow::ScheduledActionGenerator.first
  end
  
  it "should create a scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should be attached to the node" do
    @generator.node.should == Workflow::Node.named("timed_state").first
  end
  
  it "should have the appropriate interval" do
    @generator.interval.should == 3.minutes
  end
  
  it "should have the action set" do
    @generator.action.should == "do_something"
  end
  
  it "should have no transition" do
    @generator.transition.should be_nil
  end
  
  it "should repeat" do
    @generator.repeat?.should be_true
  end
  
  it "should repeat up to 3 times" do
    @generator.repeat_count.should == 3
  end
end

describe "Creating a process with a simple transition based timer" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :take_transition => :finish, :after => 5.minutes
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
    Workflow::Node.count.should == 3 # sanity check
    @generator = Workflow::ScheduledActionGenerator.first
  end
  
  it "should create a scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
  end

  it "should be attached to the node" do
    @generator.node.should == Workflow::Node.named("timed_state").first
  end
  
  it "should have the appropriate interval" do
    @generator.interval.should == 5.minutes
  end
  
  it "should have no action" do
    @generator.action.should be_nil
  end
  
  it "should have the transition set" do
    @generator.transition.should == "finish"
  end
  
  it "should not repeat" do
    @generator.repeat?.should be_false
    @generator.repeat_count.should be_nil
  end
end

describe "Creating a process with a timer with a custom generator class" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :after => 3.minutes, :generator_class => "CustomTimerGenerator"
          end
          state :end
        end
      end
    end
    CreateProcessMigration.up
  end
  
  it "should create the proper scheduled action generator" do
    Workflow::ScheduledActionGenerator.count.should == 1
    CustomTimerGenerator.count.should == 1
  end
end

describe "Creating a process with a simple action based timer without an interval" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something
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
    rescue Workflow::Migration::TimerNeedsInterval
      $!.message.should == "A timer in the node 'timed_state' needs an interval, specify with either :after or :every."
    end 
  end
end

describe "Creating a process with a timer that has neither action nor transition" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :after => 5.minutes
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
    rescue Workflow::Migration::TimerNeedsActionOrTransition
      $!.message.should == "A timer in the node 'timed_state' needs either an action to perform (use :perform) or a transition to take (use :take_transition)."
    end 
  end
end

describe "Creating a process with a timer that has both action and transition" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :duty, :take_transition => :finish, :after => 5.minutes
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
    rescue Workflow::Migration::TimerNeedsExactlyOneActionOrTransition
      $!.message.should == "A timer in the node 'timed_state' is trying to specify an action and a transition -- it can only do exactly one."
    end 
  end
end

describe "Creating a process with a timer that repeats without enumerator" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :duty, :every => 5.minutes, :up_to => 3
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
    rescue Workflow::Migration::TimerRepeatCountMustBeEnumerator
      $!.message.should == "A timer in the node 'timed_state' specified a repeat count without using an enumerator (use 3.times rather than 3)."
    end 
  end
end

describe "Creating a process with a timer with a nonexistent custom generator class" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :after => 3.minutes, :generator_class => "WhereAmI"
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
    rescue Workflow::Migration::CustomGeneratorClassDoesNotExist
      $!.message.should == "Custom generator classes must be defined; the class 'WhereAmI' in the node 'timed_state' can not be found."
    end 
  end
end

describe "Creating a process with a timer with a custom generator class that does not descend from our generator" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :timed_state
          end
          state :timed_state do
            transition :finish, :to => :end
            timer :perform => :do_something, :after => 3.minutes, :generator_class => "TestDummy"
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
    rescue Workflow::Migration::CustomGeneratorMustDescendFromWorkflowGenerator
      $!.message.should == "Custom generator classes must descend from Workflow::ScheduledActionGenerator; the class 'TestDummy' in the node 'timed_state' does not."
    end 
  end
end