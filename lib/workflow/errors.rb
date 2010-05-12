module Workflow
  # Base class for all workflow exceptions
  class Error < StandardError; end
  
  # Raised when a process is attempted to be transitioned by a transition with a name
  # that does not exist or does not correspond to a transition emanating from the current
  # node.
  class NoSuchTransition < Error; end
  
  # Raised from DecisionNode when the instance on the workflow either does not respond to
  # the name of the decision or there is no custom class of NameDecision format
  class NoWayToMakeDecision < Error; end
  
  # Raised when the custom decision class does not quack like the duck we want -- it does
  # not implement transition_to_take
  class CustomDecisionDoesntQuack < Error; end
  
  # Raised when the custom task class for a task node does not exist or does not quack like
  # a Workflow::Task
  class BadTaskClass < Error; end
  
  # Raised from ActionNode when the instance on the workflow either does not respond to
  # the name of the action or there is no custom class of NameAction format
  class NoWayToPerformAction < Error; end
  
  # Raised when the custom decision class does not quack like the duck we want -- it does
  # not implement perform
  class CustomActionDoesntQuack < Error; end
  
end