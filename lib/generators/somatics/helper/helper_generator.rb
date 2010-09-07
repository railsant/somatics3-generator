require 'generators/somatics'
# require 'rails/generators/scaffold_controller_generator'
require 'rails/generators/rails/helper/helper_generator'

module Somatics
  module Generators
    class HelperGenerator <  Rails::Generators::HelperGenerator
      
      protected
      # def class_path
      #   puts options[:namespace]
      #   @class_path.unshift(options[:namespace]) if options[:namespace].present?
      # end
    end
  end
end
