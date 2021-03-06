require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

def create_simple_task_workflow(options={})
  @process = Factory.create :process, :name => "Test Workflow"
  @start_node = Factory.create :node, :process => @process, :name => "Start", :start => true
  if options[:custom_class]
    @task_node = Factory.create :task_node, :process => @process, :name => "Do Something Custom", :assign_to => "jeff", :custom_class => options[:custom_class]
  else
    @task_node = Factory.create :task_node, :process => @process, :name => "Do Something", :assign_to => "jeff"
  end
  @transition = Factory.create :transition, :name => "go", :from_node => @start_node, :to_node => @task_node
  @end_node = Factory.create :node, :process => @process, :name => "End"
  @completed_transition = Factory.create :transition, :name => "completed", :from_node => @task_node, :to_node => @end_node
  @model = TestDummy.new
end

def perform_task_workflow
  @model.start_test_workflow
  @model.test_workflow.transition! :go
end

describe "A simple workflow with a task node" do
  before do
    create_simple_task_workflow
  end
  
  it "should create a task on entry" do
    Workflow::Task.count.should == 0
    perform_task_workflow
    @model.test_workflow.node.should == @task_node
    Workflow::Task.count.should == 1
  end
  
  it "should create a task linked to this process instance" do
    perform_task_workflow
    Workflow::Task.last.process_instance.should == @model.test_workflow
  end
  
  it "should create a task linked to the task node that created it" do
    perform_task_workflow
    Workflow::Task.last.node.should == @task_node
  end
  
  it "should create a task assigned to who it says!" do
    perform_task_workflow
    Workflow::Task.last.assigned_to.should == "jeff"
  end
  
  it "should take the 'completed' transition when the task is completed" do
    perform_task_workflow
    @model.test_workflow.node.should == @task_node
    Workflow::Task.last.complete!
    @model.test_workflow.reload.node.should == @end_node
  end
end

describe "A simple workflow with a task node using a custom task class" do
  before do
    create_simple_task_workflow :custom_class => "TestTask"
  end
  
  it "should create a custom task instance on entry" do
    TestTask.count.should == 0
    perform_task_workflow
    @model.test_workflow.node.should == @task_node
    TestTask.count.should == 1
  end
end

describe "A simple workflow with a task node using a bad custom task class" do
  before do
    create_simple_task_workflow :custom_class => "NonexistentTestTask"
  end
  
  it "should fail with an error" do
    begin
      perform_task_workflow
      fail
    rescue Workflow::BadTaskClass
    end
  end
end