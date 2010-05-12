class Workflow::Action < Workflow::Task
  def perform
    process_instance.instance.send node.name
    complete!
  end
end