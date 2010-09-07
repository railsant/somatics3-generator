require 'rails/generators/named_base'

module Somatics
  module Generators
    module TemplatePath
      def source_root
        @_somaitcs_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'somatics', generator_name, 'templates'))
      end
    end
    
    module SomaticsHelpers
      def self.included(base) #:nodoc:
        base.class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin",
                           :desc => "namespace to generate the controller for"
      end
    end
    
    # class Base < Rails::Generators::NamedBase
    #   # include Rails::Generators::ResourceHelpers
    #   
    #   def self.source_root
    #     @_somatics_source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'somatics', generator_name, 'templates'))
    #   end
    #   protected
    # 
    #   def format
    #     :html
    #   end
    # 
    #   def handler
    #     :erb
    #   end
    # 
    #   def filename_with_extensions(name)
    #     [name, format, handler].compact.join(".")
    #   end
    #   
    #   def template_filename_with_extensions(name)
    #     [name, format, handler, :erb].compact.join(".")
    #   end
    # end
  end
end