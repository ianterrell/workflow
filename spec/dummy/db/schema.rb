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

ActiveRecord::Schema.define(:version => 20100507184641) do

  create_table "workflow_nodes", :force => true do |t|
    t.string   "name"
    t.string   "type"
    t.integer  "process_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_nodes", ["name"], :name => "index_workflow_nodes_on_name"
  add_index "workflow_nodes", ["process_id"], :name => "index_workflow_nodes_on_process_id"
  add_index "workflow_nodes", ["type"], :name => "index_workflow_nodes_on_type"

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

  create_table "workflow_transitions", :force => true do |t|
    t.string   "name"
    t.integer  "from_node_id"
    t.integer  "to_node_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "workflow_transitions", ["from_node_id"], :name => "index_workflow_transitions_on_from_node_id"
  add_index "workflow_transitions", ["name"], :name => "index_workflow_transitions_on_name"
  add_index "workflow_transitions", ["to_node_id"], :name => "index_workflow_transitions_on_to_node_id"

end
