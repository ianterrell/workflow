class Workflow::Node < ActiveRecord::Base
  include_constellation
  def host_app_provided_method; end
end