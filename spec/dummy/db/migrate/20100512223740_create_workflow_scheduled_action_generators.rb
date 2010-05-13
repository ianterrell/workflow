class CreateWorkflowScheduledActionGenerators < ActiveRecord::Migration
  def self.up
    create_table :workflow_scheduled_action_generators do |t|
      t.references :node
      t.integer :interval, :repeat_count
      t.boolean :repeat, :default => false
      t.string :action, :transition, :custom_class
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_scheduled_action_generators
  end
end
