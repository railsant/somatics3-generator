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
        route_config =  " namespace :#{options[:namespace]} do \n"
        route_config << " root :to => 'home#index'\n"
        route_config << " match 'home' => 'home#index'\n"
        route_config << " end\n"
        route route_config
      end
      
      
      # # Check for class naming collisions.
      #       m.class_collisions('Admin::HomeController', 'Admin::AdminController', 'AdminHelper')
      #
      #       # Controller, helper, views, test and stylesheets directories.
      #       m.directory File.join('app/controllers/admin')
      #       m.directory File.join('app/helpers/admin')
      #       m.directory File.join('app/views/layouts')
      #       m.directory File.join('app/views/admin/shared')
      #       m.directory File.join('app/views/admin/home')
      #       m.directory File.join('test/functional/admin')
      #       m.directory File.join('public/stylesheets')
      #       m.directory File.join('public/javascripts')
      #       
      #       # Controller      
      #       m.template 'controller_admin.rb', File.join('app/controllers/admin', 'admin_controller.rb')
      #       m.template 'controller_home.rb', File.join('app/controllers/admin', 'home_controller.rb')
      #       
      #       # Helpers
      #       m.template 'helper_admin.rb', File.join('app/helpers/admin', 'admin_helper.rb')
      #       
      #       # Home Views
      #       m.template 'view_index.html.erb', File.join('app/views/admin', 'home', 'index.html.erb')
      #       
      #       # Layouts
      #       m.template 'layout_admin.html.erb', File.join('app/views/layouts', "admin.html.erb")
      #       m.template 'partial_menu.html.erb', File.join('app/views/admin/shared', "_menu.html.erb")
      #       
      #       # Stylesheets and Javascripts.
      #       m.template_without_destroy 'admin.js', 'public/javascripts/admin/admin.js'
      #       # m.template_without_destroy 'css_admin.css', 'public/stylesheets/admin.css'
      #       # m.template_without_destroy 'css_jstoolbar.css', 'public/stylesheets/jstoolbar.css'
      #       # m.template_without_destroy 'css_context_menu.css', 'public/stylesheets/context_menu.css'
      #       # m.template_without_destroy 'css_csshover.htc', 'public/stylesheets/csshover.htc'      
      #       # m.template_without_destroy 'js_context_menu.js', 'public/javascripts/context_menu.js'
      #       # m.template_without_destroy 'js_select_list_move.js', 'public/javascripts/select_list_move.js'
      #       
      #       # Images
      #       # Dir.foreach "#{RAILS_ROOT}/vendor/plugins/somatics_generator/generators/admin_controllers/templates/images/" do |f|
      #       #   m.file "images/#{f}", "public/images/#{f}", :collision => :skip
      #       # end
      #       
      #       # Mime Types
      #       # m.template 'mime_types.rb', File.join('config/initializers',"mime_types.rb"), :collision => :force
      #       m.mime_type('application/vnd.ms-excel',:xls)
      #       
      #       %w( en zh-TW ).each do |locale|
      #         m.template "locales_#{locale}.yml", File.join('config/locales', "admin_#{locale}.yml")
      #       end
      #       
      #       # Routing
      #       m.admin_route_root :controller => 'home', :action => 'index'
      #       m.admin_route_name 'home', '/admin/index', {:controller => 'home', :action => 'index'}

    end
  end
end
