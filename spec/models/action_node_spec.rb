require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::ActionNode do
  it { should have_many(:actions) }
end