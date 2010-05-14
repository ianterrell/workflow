class CustomNode < Workflow::Node
  def execute_enter_callbacks(process_instance)
    super
    @@entered_count ||= 0
    @@entered_count += 1
  end
  
  def self.entered_count
    @@entered_count ||= 0
  end
end