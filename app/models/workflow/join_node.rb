# This is a node that automatically joins the process when all incoming transitions have entered.
# 
# If there are multiple branches (created with a ForkNode) entering this node, then all but the 
# last wait here.  Once the last one arrives (determined by comparing the number of ProcessInstanceNode
# instances waiting here with the total number of incoming transitions), the instance is transitioned
# out along the 'continue' transition.
#
# No longer needed ProcessInstanceNode instances are destroyed.
class Workflow::JoinNode < Workflow::Node
  def execute_enter_callbacks(process_instance) #:nodoc:
    super
    
    # If we're ready to go
    process_instance_nodes_here = process_instance.process_instance_nodes.for_node(self)
    if process_instance_nodes_here.size == incoming_transitions.count
      # Destroy all but one process instance node
      process_instance_nodes_here.each_with_index do |pin, index|
        pin.destroy unless index == 0
      end
      
      # Transition the remaining one out
      process_instance.transition! :continue, self
    end
  end
end