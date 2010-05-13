class CreateWorkflowScheduledActionGenerators < ActiveRecord::Migration
  def self.up
    create_table :workflow_scheduled_action_generators do |t|
      t.references :node
      t.integer :interval, :repeat_count
      t.boolean :repeat, :default => false
      t.string :action, :transition, :custom_class
      t.timestamps
    end
    add_index :workflow_scheduled_action_generators, :node_id
  end

  def self.down
    remove_index :workflow_scheduled_action_generators, :node_id
    drop_table :workflow_scheduled_action_generators
  end
end
