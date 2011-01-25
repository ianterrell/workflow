class Workflow::Node < ActiveRecord::Base
  include_workflow
  def host_app_provided_method; end
end