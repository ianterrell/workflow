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

  def guards_are_valid
    valid = (guards.is_a?(Array) ? guards : [guards]).all? { |c| guard_is_valid?(c) }
    self.errors.add(:guards, "must be nil, symbols, strings, or arrays of them ending in ?") unless valid
  end

  def guard_is_valid?(guard)
    guard.nil? || ((guard.is_a?(String) || guard.is_a?(Symbol)) && guard.to_s.ends_with?('?'))
  end
end
