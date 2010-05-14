module Workflow
  require 'workflow/engine' if defined?(Rails)
  
  # Returns true if a class specified by an underscored string (e.g. "my_custom_class") exists.
  def self.custom_class_exists?(underscored_clazz_string)
    clazz = custom_class(underscored_clazz_string) rescue nil
    !clazz.nil?
  end
  
  # Turns an underscored string (e.g. "my_custom_class") into its corresponding class object
  # (e.g. MyCustomClass) by camelizing it and constantizing it.
  def self.custom_class(underscored_clazz_string)
    underscored_clazz_string.camelize.constantize
  end
end