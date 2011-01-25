module Workflow
  module ObjectExtensions
    def self.included(recipient)
      recipient.extend ObjectClassMethods
      # recipient.class_eval { include ObjectInstanceMethods }
    end

    module ObjectClassMethods
      # This method is to be used inside a class in your RAILS_ROOT/app with which you
      # would like to extend the Workflow-provided functionality rather than
      # completely replace it.
      #
      # Usage:
      #   include_workflow
      def include_workflow(options={})
        modules = [:workflow]
        filename = self.name.underscore
        found = false
        modules.each do |m|
          if Rails.application.config.include? m
            root = Rails.application.config.send(m).root
            ["/lib/", "/app/controllers/", "/app/models/", "/app/mailers/", "/app/helpers/"].each do |path|
              begin
                require_dependency root + path + filename 
                found = true
              rescue LoadError
              end
            end
          end
        end
        raise LoadError.new unless found
      end
    end
  end
end