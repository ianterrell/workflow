class CreateWorkflowTasks < ActiveRecord::Migration
  def self.up
    create_table :workflow_tasks do |t|
      t.references :node, :process_instance
      t.string :assigned_to
      t.datetime :completed_at
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_tasks
  end
end
