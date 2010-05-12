require File.join(File.dirname(__FILE__), '..', 'spec_helper.rb')

describe Workflow::TaskNode do
  it { should have_many(:tasks) }
end