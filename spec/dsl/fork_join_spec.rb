require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Creating a process with a named decision node" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :my_fork
          end
          fork :my_fork do
            transition :a, :to => :a
            transition :b, :to => :b
          end
          state :a do
            transition :continue, :to => :my_join
          end
          state :b do
            transition :continue, :to => :my_join
          end
          join :my_join do
            transition :continue, :to => :end
          end     
          state :end
        end
      end
    end
    CreateProcessMigration.up
    @node = Workflow::DecisionNode.first
  end
  
  it "should create the process" do
    Workflow::Process.count.should == 1
    Workflow::Process.first.name.should == "Test Workflow"
  end
  
  it "should create the fork node" do
    Workflow::ForkNode.count.should == 1
  end
  
  it "should create the join node" do
    Workflow::JoinNode.count.should == 1
  end
  
  it "should name the join node properly" do
    Workflow::JoinNode.first.name.should == "my_join"
  end
  
  it "should name the fork node properly" do
    Workflow::ForkNode.first.name.should == "my_fork"
  end  
end

describe "Creating a process with a fork without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :my_fork
          end
          fork do
            transition :a, :to => :a
            transition :b, :to => :b
          end
          state :a do
            transition :continue, :to => :my_join
          end
          state :b do
            transition :continue, :to => :my_join
          end
          join :my_join do
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

describe "Creating a process with a join without a name" do
  before do
    class CreateProcessMigration < Workflow::Migration
      def self.up
        create_process "Test Workflow" do
          state :start, :start_state => true do
            transition :go, :to => :my_fork
          end
          fork :my_fork do
            transition :a, :to => :a
            transition :b, :to => :b
          end
          state :a do
            transition :continue, :to => :my_join
          end
          state :b do
            transition :continue, :to => :my_join
          end
          join do
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