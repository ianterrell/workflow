# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100512233128) do

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_dummies", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_nodes", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.string   "custom_class"
    t.string   "assign_to"
    t.text     "enter_callbacks"
    t.text     "exit_callbacks"
    t.integer  "process_id"
    t.boolean  "start",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_nodes", ["name"], :name => "index_workflow_nodes_on_name"
  add_index "workflow_nodes", ["process_id"], :name => "index_workflow_nodes_on_process_id"
  add_index "workflow_nodes", ["type"], :name => "index_workflow_nodes_on_type"

  create_table "workflow_process_instance_nodes", :force => true do |t|
    t.integer  "node_id"
    t.integer  "process_instance_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_process_instance_nodes", ["node_id"], :name => "index_workflow_process_instance_nodes_on_node_id"
  add_index "workflow_process_instance_nodes", ["process_instance_id"], :name => "index_workflow_process_instance_nodes_on_process_instance_id"

  create_table "workflow_process_instances", :force => true do |t|
    t.integer  "instance_id"
    t.string   "instance_type"
    t.integer  "process_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_process_instances", ["instance_id"], :name => "index_workflow_process_instances_on_instance_id"
  add_index "workflow_process_instances", ["instance_type"], :name => "index_workflow_process_instances_on_instance_type"
  add_index "workflow_process_instances", ["process_id"], :name => "index_workflow_process_instances_on_process_id"

  create_table "workflow_processes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_processes", ["name"], :name => "index_workflow_processes_on_name"

  create_table "workflow_scheduled_action_generators", :force => true do |t|
    t.integer  "node_id"
    t.integer  "interval"
    t.integer  "repeat_count"
    t.boolean  "repeat",       :default => false
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_tasks", :force => true do |t|
    t.integer  "node_id"
    t.integer  "process_instance_id"
    t.integer  "generator_id"
    t.string   "assigned_to"
    t.string   "type"
    t.datetime "completed_at"
    t.datetime "scheduled_for"
    t.datetime "canceled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workflow_transitions", :force => true do |t|
    t.string   "name"
    t.text     "callbacks"
    t.text     "guards"
    t.integer  "from_node_id"
    t.integer  "to_node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_transitions", ["from_node_id"], :name => "index_workflow_transitions_on_from_node_id"
  add_index "workflow_transitions", ["name"], :name => "index_workflow_transitions_on_name"
  add_index "workflow_transitions", ["to_node_id"], :name => "index_workflow_transitions_on_to_node_id"

end
