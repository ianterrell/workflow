class CreateWorkflowScheduledActionGenerators < ActiveRecord::Migration
  def self.up
    create_table :workflow_scheduled_action_generators do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_scheduled_action_generators
  end
end
