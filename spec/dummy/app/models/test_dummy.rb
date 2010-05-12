class TestDummy < ActiveRecord::Base
  cattr_accessor :grumpy
  cattr_accessor :bar_called
  
  on_workflow "Test Workflow"
  
  def grumpy?
    @@grumpy
  end
  
  def bar
    @@bar_called ||= 0
    @@bar_called += 1
  end
  
  def always_true?
    true
  end
end