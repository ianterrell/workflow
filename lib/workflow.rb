module Workflow
  require 'workflow/engine' if defined?(Rails)
  
  def self.custom_class_exists?(underscored_clazz_string)
    clazz = custom_class(underscored_clazz_string) rescue nil
    !clazz.nil?
  end
  
  def self.custom_class(underscored_clazz_string)
    underscored_clazz_string.camelize.constantize
  end
end