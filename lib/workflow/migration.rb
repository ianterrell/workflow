module Workflow
  class Migration    
    class << self
      def up
        raise Workflow::Migration::UpNotDefined
      end
      
      def down
        raise Workflow::Migration::DownNotDefined
      end
    
      def create_process(name)
        Workflow::Process.transaction do
          @process = Workflow::Process.create! :name => name
          yield if block_given?
          raise ProcessMustHaveStartState if @process.start_node.nil?
        end
      end
      
      def destroy_process(name)
        Workflow::Process.find_by_name(name).destroy
      end
      
      def state(name, options={})
        raise StateMustBeWithinProcess unless @process
        @node = @process.nodes.create! :name => name.to_s, :start => options[:start_state]
        
      end
    end
    
    class Error < StandardError; end
    class UpNotDefined < Error; end
    class DownNotDefined < Error; end
    class ProcessMustHaveStartState < Error; end
    class StateMustBeWithinProcess < Error; end
  end
end
