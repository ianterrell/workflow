# An Action is an automatically executed Task.  When completed, the workflow is transitioned
# along the 'completed' transition.
# 
# This is the default implementation of an action created by an ActionNode if it interprets
# its name as a signal that should be sent to the model.  For instance, if the ActionNode's name
# is 'foo' and the model on the workflow respond_to?("foo"), then this class will be instantiated
# and when the action is performed the signal "foo" will be sent to the model.
class Workflow::Action < Workflow::Task
  # Sends the signal of the ActionNode's name to the model and completes the task.
  # I.e. if the ActionNode's name is "foo" this method sends "foo" to the model
  # and then execute's complete!, which advances the workflow.
  def perform
    process_instance.instance.send node.name
    complete!
  end
end