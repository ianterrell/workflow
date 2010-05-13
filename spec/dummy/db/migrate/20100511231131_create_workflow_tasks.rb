class CreateWorkflowTasks < ActiveRecord::Migration
  def self.up
    create_table :workflow_tasks do |t|
      t.references :node, :process_instance, :generator, :delayed_job
      t.string :assigned_to, :type
      t.datetime :completed_at, :scheduled_for, :canceled_at
      t.timestamps
    end
    add_index :workflow_tasks, :node_id
    add_index :workflow_tasks, :process_instance_id
    add_index :workflow_tasks, :generator_id
    add_index :workflow_tasks, :delayed_job_id
    add_index :workflow_tasks, :type
  end

  def self.down
    remove_index :workflow_tasks, :type
    remove_index :workflow_tasks, :delayed_job_id
    remove_index :workflow_tasks, :generator_id
    remove_index :workflow_tasks, :process_instance_id
    remove_index :workflow_tasks, :node_id
    drop_table :workflow_tasks
  end
end
