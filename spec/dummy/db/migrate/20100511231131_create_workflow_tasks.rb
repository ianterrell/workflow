class CreateWorkflowTasks < ActiveRecord::Migration
  def self.up
    create_table :workflow_tasks do |t|
      t.references :node, :process_instance
      t.string :assigned_to, :type
      t.datetime :completed_at, :scheduled_for
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_tasks
  end
end
