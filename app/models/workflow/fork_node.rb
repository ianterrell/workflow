# This is a node that automatically forks the process and follows all of its transitions when the instance enters.
# 
# Additional ProcessInstanceNode instances are created to handle the additional branches of the process.
class Workflow::ForkNode < Workflow::Node
  def execute_enter_callbacks(process_instance) #:nodoc:
    super
    # Create enough process instance nodes for all of our outgoing transitions, reusing the current one
    (transitions.count - 1).times { process_instance.process_instance_nodes.create! :node => self }
    
    # Transition them all out
    transitions.each_with_index do |transition, index|
      process_instance.transition! transition.name, process_instance.process_instance_nodes[index]
    end
  end
end