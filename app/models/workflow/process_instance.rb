class Workflow::ProcessInstance < ActiveRecord::Base
  belongs_to :instance, :polymorphic => true
  belongs_to :process, :class_name => "Workflow::Process", :foreign_key => "process_id"
end
