module Workflow
  # Raised when a process is attempted to be transitioned by a transition with a name
  # that does not exist or does not correspond to a transition emanating from the current
  # node.
  class NoSuchTransition < StandardError; end
  
  # Raised from DecisionNode when the instance on the workflow either does not respond to
  # the name of the decision or there is no custom class of NameDecision format
  class NoWayToMakeDecision < StandardError; end
  
  # Raised when the custom decision class does not quack like the duck we want -- it does
  # not implement transition_to_take
  class CustomDecisionDoesntQuack < StandardError; end
end