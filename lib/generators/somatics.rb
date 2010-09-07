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
    
    # class AssetsGenerator < Rails::Generators::Base
    # 
    #   # include Rails::Generators::Migration
    # 
    #   # source_root File.expand_path("../../templates", __FILE__)
    # 
    #   namespace "somatics"
    # 
    #   class_option :admin_title, :default => Rails.root.basename
    # 
    #   def generate_initializer
    #     # template "config/initializers/somatics.rb", "config/initializers/somatics.rb"
    #     # template "config/initializers/somatics_resources.rb", "config/initializers/somatics_resources.rb"
    #   end
    # 
    #   def copy_assets
    #     # templates_path = File.expand_path("../../templates", __FILE__)
    #     # Dir["#{templates_path}/public/**/*.*"].each do |file|
    #     #   copy_file file.split("#{templates_path}/").last
    #     # end
    #   end
    # 
    #   #--
    #   # Generate files for models:
    #   #   `#{controllers_path}/#{resource}_controller.rb`
    #   #   `#{tests_path}/#{resource}_controller_test.rb`
    #   #++
    #   def generate_controllers
    #     # Somatics.application_models.each do |model|
    #     #   klass = model.constantize
    #     #   @resource = klass.name.pluralize
    #     #   template "controller.rb", "#{controllers_path}/#{klass.to_resource}_controller.rb"
    #     #   template "functional_test.rb",  "#{tests_path}/#{klass.to_resource}_controller_test.rb"
    #     # end
    #   end
    # 
    #   def generate_config
    #     # configuration = generate_yaml_files
    #     # unless configuration[:base].empty?
    #     #   %w( application.yml application_roles.yml ).each do |file|
    #     #     from = to = "config/typus/#{file}"
    #     #     if File.exists?(from) then to = "config/typus/#{timestamp}_#{file}" end
    #     #     @configuration = configuration
    #     #     template from, to
    #     #   end
    #     # end
    #   end
    # 
    #   protected
    # 
    # end
    
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