class TestDecision
  def initialize(instance)
  end
  
  cattr_accessor :value
  def transition_to_take
    value
  end
end