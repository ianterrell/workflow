class CreateWorkflowTransitions < ActiveRecord::Migration
  def self.up
    create_table :workflow_transitions do |t|
      t.string :name
      t.text :callbacks
      t.references :from_node
      t.references :to_node
      t.timestamps
    end
    add_index :workflow_transitions, :name
    add_index :workflow_transitions, :from_node_id
    add_index :workflow_transitions, :to_node_id
  end

  def self.down
    remove_index :workflow_transitions, :to_node_id
    remove_index :workflow_transitions, :from_node_id
    remove_index :workflow_transitions, :name
    drop_table :workflow_transitions
  end
end
