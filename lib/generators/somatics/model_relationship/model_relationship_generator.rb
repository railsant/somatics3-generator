require 'generators/somatics'
require 'rails/generators/named_base'
module Somatics
  module Generators
    class ModelRelationshipGenerator < Rails::Generators::Base
      extend TemplatePath
      include Rails::Generators::ResourceHelpers

      # hook_for :scaffold_controller, :required => true # do |controller|
       #        invoke controller, [ controller_name, attributes], {:namespace => 'admin' }
       #      end

      # 
      # class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin",
      #                         :desc => "namespace to generate the controller for"

      # include SomaticsHelpers

      # remove_hook_for :resource_controller
      # remove_class_option :actions
      
      # default_options :skip_migration => false,
      #                       :skip_views => false
      #       attr_reader :relationship, :reference_value
      #       attr_reader :model_name, :class_name
      #       attr_reader :reference_model_name, :reference_class_name
      #       attr_reader :migration_table_name, :migration_attribute

      # def initialize(runtime_args, runtime_options = {})
      #        super
      # 
      #        @runtime_args = runtime_args
      #        @command = @runtime_args.first
      #        raise banner unless match_data = @command.match(/(.*)_(has_many|belongs_to)_(.*)/)
      #        @relationship = match_data[2]
      #        @model_name = match_data[1].singularize
      #        @class_name = @model_name.camelize
      #        @reference_model_name = match_data[3].singularize
      #        @reference_class_name = @reference_model_name.camelize
      #        case @relationship
      #          when 'has_many'
      #            @reference_value = @reference_model_name.pluralize
      #            @migration_model_name = @reference_model_name
      #            @migration_table_name = @reference_value
      #            @migration_attribute = "#{@model_name}_id"
      #          when 'belongs_to'
      #            # @reference_value = @reference_model_name
      #            # @migration_model_name = @model_name
      #            # @migration_table_name = @model_name.pluralize
      #            # @migration_attribute = "#{@reference_model_name}_id"
      #        end
      #      end
       def dump_generator_attribute_names
          generator_attribute_names = [
            :table_name,
            :file_name,
            :class_name,
          ]

          generator_attribute_names.each do |attr|
            puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
          end

        end
    end
  end
end
