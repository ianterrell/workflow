class CreateWorkflowNodes < ActiveRecord::Migration
  def self.up
    create_table :workflow_nodes do |t|
      t.string :name, :type
      t.references :process
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