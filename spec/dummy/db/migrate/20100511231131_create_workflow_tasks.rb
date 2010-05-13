class CreateWorkflowTasks < ActiveRecord::Migration
  def self.up
    create_table :workflow_tasks do |t|
      t.references :node, :process_instance, :generator, :delayed_job
      t.string :assigned_to, :type
      t.datetime :completed_at, :scheduled_for, :canceled_at
      t.timestamps
    end
  end

  def self.down
    drop_table :workflow_tasks
  end
end
