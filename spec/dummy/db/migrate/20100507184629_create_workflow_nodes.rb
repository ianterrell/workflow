class CreateWorkflowNodes < ActiveRecord::Migration
  def self.up
    create_table :workflow_nodes do |t|
      t.string :name, :type, :custom_class, :assign_to
      t.text :enter_callbacks, :exit_callbacks
      t.references :process
      t.boolean :start, :default => false
      t.timestamps
    end
    add_index :workflow_nodes, :name
    add_index :workflow_nodes, :type
    add_index :workflow_nodes, :process_id
  end

  def self.down
    remove_index :workflow_nodes, :process_id
    remove_index :workflow_nodes, :type
    remove_index :workflow_nodes, :name
    drop_table :workflow_nodes
  end
end
