require 'workflow'
require 'app/models/workflow/process'
require 'app/models/workflow/process_instance'
require 'app/models/workflow/node'
require 'app/models/workflow/transition'

Factory.define :process, :class => Workflow::Process, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Test Process #{n}" }
end

Factory.define :process_instance, :class => Workflow::ProcessInstance, :default_strategy => :build do |f|
  f.association :process
end

Factory.define :node, :class => Workflow::Node, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Test Node #{n}" }
  f.association :process
end

Factory.define :transition, :class => Workflow::Transition, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Test Transition #{n}" }
  f.association :from_node, :factory => :node
  f.association :to_node, :factory => :node
end

