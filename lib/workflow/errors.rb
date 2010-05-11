module Workflow
  class NoSuchTransition < StandardError; end
  class NoWayToMakeDecision < StandardError; end
  class CustomDecisionDoesntQuack < StandardError; end
end