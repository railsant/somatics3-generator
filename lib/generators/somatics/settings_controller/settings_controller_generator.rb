require 'generators/somatics'
require 'rails/generators/resource_helpers'
require 'generators/somatics/scaffold_controller/scaffold_controller_generator'

module Somatics
  module Generators
    class SettingsControllerGenerator <  ScaffoldControllerGenerator
      extend TemplatePath
    end
  end
end
