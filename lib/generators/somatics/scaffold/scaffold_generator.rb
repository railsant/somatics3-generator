require 'generators/somatics'
require 'rails/generators/rails/resource/resource_generator'
require 'rails/generators/resource_helpers'

module Somatics
  module Generators
    class ScaffoldGenerator < Rails::Generators::ModelGenerator #metagenerator
      include Rails::Generators::ResourceHelpers

      hook_for :resource_controller, :in => :rails, :as => :controller, :required => true do |controller|
        invoke controller, [ options[:namespace] + '/' + controller_name, options[:actions] ]
      end

      class_option :actions, :type => :array, :banner => "ACTION ACTION", :default => [],
                             :desc => "Actions for the resource controller"

      class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin",
                              :desc => "namespace to generate the controller for"


      def add_resource_route
        return if options[:actions].present?
        route_config =  class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
        route_config << "resources :#{file_name.pluralize}"
        route_config << " end" * class_path.size
        route route_config
      end
      # include SomaticsHelpers

      # remove_hook_for :resource_controller
      # remove_class_option :actions
      
      # hook_for :assets #TODO copy assets to public and config/locales
      # hook_for :i18n_files #TODO copy i18n_files to config/locales
      
    end
  end
end
