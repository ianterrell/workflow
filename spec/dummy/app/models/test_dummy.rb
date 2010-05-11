class TestDummy < ActiveRecord::Base
  cattr_accessor :grumpy
  
  on_workflow "Test Workflow"
  
  def grumpy?
    @@grumpy
  end
end