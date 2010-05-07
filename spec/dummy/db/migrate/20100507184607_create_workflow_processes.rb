class CreateWorkflowProcesses < ActiveRecord::Migration
  def self.up
    create_table :workflow_processes do |t|
      t.string :name
      t.timestamps
    end
    add_index :workflow_processes, :name
  end

  def self.down
    remove_index :workflow_processes, :name
    drop_table :workflow_processes
  end
end
