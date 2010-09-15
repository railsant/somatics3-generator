require 'generators/somatics'
require 'rails/generators/named_base'

module Somatics
  module Generators
    class InstallGenerator < Rails::Generators::Base
      extend TemplatePath
      class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin", :desc => "namespace to generate the controller for"
      
      def public_directory
        directory "public", "public", :recursive => false
      end

      def images
        directory "public/images"
      end

      def stylesheets
        directory "public/stylesheets"
      end

      def javascripts
        directory "public/javascripts"
      end

      def base
        template 'controller_admin.rb', File.join('app/controllers/admin', 'admin_controller.rb')
        template 'helper_admin.rb', File.join('app/helpers/admin', 'admin_helper.rb')
      end
      
      def home
        template 'controller_home.rb', File.join('app/controllers/admin', 'home_controller.rb')
        template 'view_index.html.erb', File.join('app/views/admin', 'home', 'index.html.erb')
      end
      
      def layouts
        template 'layout_admin.html.erb', File.join('app/views/layouts', "admin.html.erb")
        template 'partial_menu.html.erb', File.join('app/views/admin/shared', "_menu.html.erb")
      end
      
      def mime_type
        gsub_file File.join('config','initializers', 'mime_types.rb'), "Mime::Type.register 'application/vnd.ms-excel', :xls", ""
        append_file File.join('config','initializers', 'mime_types.rb'), "Mime::Type.register 'application/vnd.ms-excel', :xls"
      end
      
      def locales
        directory "config/locales"
      end
      
      def add_route
        route_config = ""
        route_config << "\tnamespace :#{options[:namespace]} do \n" if options[:namespace].present?
        route_config << "\t\troot :to => 'home#index'\n"
        route_config << "\t\tmatch 'home' => 'home#index'\n"
        route_config << "\tend\n" if options[:namespace].present?
        route route_config
      end
      
      def add_initializer
        directory "config/initializers"
      end
      
    end
  end
end
