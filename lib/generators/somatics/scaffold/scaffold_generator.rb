require 'generators/somatics'
require 'rails/generators/rails/resource/resource_generator'
require 'rails/generators/resource_helpers'

module Somatics
  module Generators
    class ScaffoldGenerator < Rails::Generators::ModelGenerator #metagenerator
      include Rails::Generators::ResourceHelpers

      hook_for :scaffold_controller, :required => true # do |controller|
       #        invoke controller, [ controller_name, attributes], {:namespace => 'admin' }
       #      end

      # 
      # class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin",
      #                         :desc => "namespace to generate the controller for"

      # include SomaticsHelpers

      # remove_hook_for :resource_controller
      # remove_class_option :actions
    end
  end
end
