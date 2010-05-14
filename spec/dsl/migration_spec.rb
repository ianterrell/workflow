require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe "Running a migration without an up" do
  before do
    class NoUpMigration < Workflow::Migration
    end
  end
  
  it "should raise an exception" do
    begin
      NoUpMigration.up
      fail
    rescue Workflow::Migration::Error
      $!.message.should == "Your migration must provide the class level 'up' method."
    end 
  end
end

describe "Running a migration without a down" do
  before do
    class NoDownMigration < Workflow::Migration
    end
  end
  
  it "should raise an exception" do
    begin
      NoDownMigration.down
      fail
    rescue Workflow::Migration::Error
      $!.message.should == "Your migration must provide the class level 'down' method."
    end 
  end
end