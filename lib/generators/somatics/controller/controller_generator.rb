require 'generators/somatics'
require 'rails/generators/erb/controller/controller_generator'

module Somatics
  module Generators
    class ControllerGenerator < Erb::Generators::ControllerGenerator
      extend TemplatePath
    end
  end
end
