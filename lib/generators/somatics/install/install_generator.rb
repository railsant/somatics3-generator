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
      
      def themes
        directory "public/themes"
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
        template 'partial_menu.html.erb', File.join('app/views/admin/shared', "_menu.html.erb"), :skip => true
      end
      
      def mime_type
        gsub_file File.join('config','initializers', 'mime_types.rb'), "Mime::Type.register 'application/vnd.ms-excel', :xls", ""
        append_file File.join('config','initializers', 'mime_types.rb'), "Mime::Type.register 'application/vnd.ms-excel', :xls"
      end
      
      def locales
        directory "config/locales"
      end
      
      def default_admin
        rakefile "somatics.rake" do 
          <<-RUBY
namespace :somatics do
  desc "Create Default Admin User"
  task :create_user => :environment do
    User.find_or_create_by_name(:name => 'Admin', :password => 'somatics', :password_confirmation => 'somatics', :email => 'admin@somatics.com')
  end
end
          RUBY
        end
      end
      
      def add_settings
        append_file File.join('db','seeds.rb') do 
          <<-RUBY
          unless Setting.find_by_name('theme')
            s = Setting.new
            s.name = 'theme'
            s.category = 'General'
            s.value = 'default'
            s.field_type = 'string'
            s.save!
          end
          RUBY
        end
      end
      
      def add_route
        route_config = ""
        route_config << "  namespace :#{options[:namespace]} do \n" if options[:namespace].present?
        route_config << "    root :to => 'home#index'\n"
        route_config << "    match 'home' => 'home#index'\n"
        route_config << "  end\n" if options[:namespace].present?
        route route_config
      end
      
      def libs
        directory "lib"
      end

      def paper_trail
        template 'partial_versions.html.erb', File.join('app/views/admin/shared', "_versions.html.erb")
        template 'initializer_paper_trail.rb', File.join('config/initializers', "paper_trail.rb")
      end
    end
  end
end
