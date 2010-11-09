require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
# require 'digest/sha1'
# require 'rails/generators/migration'
        
module Somatics
  module Generators
    class AuthenticatedControllerGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      
      class_option :namespace, :banner => "NAME", :type => :string, :default => ''
      class_option :locales, :type => :array, :banner => "LOCALE LOCALE", :default => %w( en zh-TW ),
                             :desc => "Supported Locales"
      
      def create_sessions_controller
        template 'sessions_controller.rb', File.join('app/controllers', options.namespace, "#{name}_sessions_controller.rb")
      end
      
      def create_login_page
        template 'login.html.erb', File.join("app/views", options.namespace, "#{name}_sessions", 'new.html.erb')
      end
      
      def create_locales
        options[:locales].each do |locale|
          template "locales_#{locale}.yml", File.join('config/locales', "#{name}_sessions_#{locale}.yml")
        end
      end

      protected
      
      def namespace_class
        options.namespace.camelize
      end

    end
  end
end
