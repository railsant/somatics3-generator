require 'generators/somatics'
# require 'rails/generators/scaffold_controller_generator'
require 'rails/generators/rails/scaffold_controller/scaffold_controller_generator'

module Somatics
  module Generators
    class ScaffoldControllerGenerator <  Rails::Generators::ScaffoldControllerGenerator
      extend TemplatePath
      include SomaticsHelpers

      remove_hook_for :template_engine, :test_framework, :helper # TODO
      hook_for :helper, :in => :rails do |i,o|
        i.invoke 
      end
      
      # desc "This generator creates an admin controller with namespace"
      # def create_controller_files
      #   template 'controller.rb', File.join('app/controllers', class_path, options[:namespace] ,"#{controller_file_name}_controller.rb")
      # end
      # 
      # desc "This generator creates an admin controller with namespace"
      # def add_resource_route
      #   route_config =  class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
      #   route_config << "resources :#{file_name.pluralize}"
      #   route_config << " end" * class_path.size
      #   route route_config
      # end
      
      protected
        def class_path
           @class_path.unshift(options[:namespace])
        end
    end
  end
end
