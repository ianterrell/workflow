# A Transition defines a named relationship between two nodes.  To analogize, they are the roads in between the cities (nodes)
# on the map (process).
#
# Transitions may have callbacks defined, which represent methods that are executed on the model instance when it takes
# the transition( behavior defined in Callbacks).  
# They may also have guards defined, which represent predicate methods (ending in ?) on the model
# that should return true or false to determine if the model is allowed to take this transition.
class Workflow::Transition < ActiveRecord::Base
  include Workflow::Callbacks
  
  belongs_to :from_node, :class_name => "Workflow::Node", :foreign_key => "from_node_id"
  belongs_to :to_node, :class_name => "Workflow::Node", :foreign_key => "to_node_id"
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :from_node_id
  
  serialize :guards
  validate :guards_are_valid
  
  has_callbacks
  
  scope :named, lambda { |name| where(:name => name) }
  
  delegate :process, :to => :from_node
  
  # If no guards are defined, this method returns true.
  # If guards are defined, this method returns true if they all return true when sent to the model instance.
  # If the model instance does not respond to a particular guard, a warning is logged but it is assumed to return true.
  def guards_pass?(instance)
    return true if guards.nil?
    (guards.is_a?(Array) ? guards : [guards]).all? do |guard| 
      if instance.respond_to? guard
        instance.send guard
      else
        logger.warn "Instance #{instance.inspect} does not respond to guard #{guard} defined on transition '#{name}' on workflow node '#{from_node.name}' in process '#{process.name}'"
        true
      end
    end
  end

protected

  def guards_are_valid #:nodoc:
    valid = (guards.is_a?(Array) ? guards : [guards]).all? { |c| guard_is_valid?(c) }
    self.errors.add(:guards, "must be nil, symbols, strings, or arrays of them ending in ?") unless valid
  end

  def guard_is_valid?(guard) #:nodoc:
    guard.nil? || ((guard.is_a?(String) || guard.is_a?(Symbol)) && guard.to_s.ends_with?('?'))
  end
end
