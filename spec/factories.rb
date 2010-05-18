require 'workflow'
require 'app/models/workflow/process'
require 'app/models/workflow/process_instance'
require 'app/models/workflow/process_instance_node'
require 'app/models/workflow/node'
require 'app/models/workflow/decision_node'
require 'app/models/workflow/task_node'
require 'app/models/workflow/action_node'
require 'app/models/workflow/fork_node'
require 'app/models/workflow/join_node'
require 'app/models/workflow/transition'
require 'app/models/workflow/task'
require 'app/models/workflow/action'
require 'app/models/workflow/scheduled_action'
require 'app/models/workflow/scheduled_action_generator'
require 'spec/dummy/app/models/custom_node'
require 'spec/dummy/app/models/custom_timer_generator'

# Huh.  Just realized that some of these factories contain inconsistent data -- like
# a transition transitioning between processes.  This needs a bit of work.

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

Factory.define :decision_node, :class => Workflow::DecisionNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "test_decision_#{n}" }
  f.association :process
end

Factory.define :task_node, :class => Workflow::TaskNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Task Node #{n}" }
  f.association :process
end

Factory.define :action_node, :class => Workflow::ActionNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Action Node #{n}" }
  f.association :process
end

Factory.define :fork_node, :class => Workflow::ForkNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Fork Node #{n}" }
  f.association :process
end

Factory.define :join_node, :class => Workflow::JoinNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Join Node #{n}" }
  f.association :process
end

Factory.define :custom_node, :class => CustomNode, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Custom Node #{n}" }
  f.association :process
end

Factory.define :transition, :class => Workflow::Transition, :default_strategy => :build do |f|
  f.sequence(:name) { |n| "Test Transition #{n}" }
  f.association :from_node, :factory => :node
  f.association :to_node, :factory => :node
end

Factory.define :process_instance_node, :class => Workflow::ProcessInstanceNode, :default_strategy => :build do |f|
  f.association :process_instance
  f.association :node
end

Factory.define :task, :class => Workflow::Task, :default_strategy => :build do |f|
  f.association :node, :factory => :task_node
  f.association :process_instance
end

Factory.define :action, :class => Workflow::Action, :default_strategy => :build do |f|
  f.association :node, :factory => :action_node
  f.association :process_instance
end

Factory.define :scheduled_action_generator, :class => Workflow::ScheduledActionGenerator, :default_strategy => :build do |f|
  f.association :node
end

Factory.define :custom_timer_generator, :class => CustomTimerGenerator, :default_strategy => :build do |f|
  f.association :node
end

Factory.define :scheduled_action, :class => Workflow::ScheduledAction, :default_strategy => :build do |f|
  f.association :process_instance
  f.scheduled_for Time.now + 5.minutes
end