require 'generators/somatics'
require 'rails/generators/resource_helpers'

module Somatics
  module Generators
    class ScaffoldControllerGenerator <  Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::ResourceHelpers

      check_class_collision :suffix => "Controller"
      # remove_hook_for :template_engine, :test_framework, :helper # TODO
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      
      class_option :orm, :banner => "NAME", :type => :string, :required => true,
                         :desc => "ORM to generate the controller for"
      class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin", :desc => "namespace to generate the controller for"
      class_option :header, :type => :boolean, :default => true, :desc => "generate header menu tab"
      class_option :locales, :type => :array, :banner => "LOCALE LOCALE", :default => %w( en zh-TW ),
                             :desc => "Supported Locales"

      def create_controller_files
        template 'controller.rb', File.join('app/controllers', options[:namespace], class_path, "#{controller_file_name}_controller.rb")
      end
      def create_view_files
        template "partial_form.html.erb",     File.join('app/views',options[:namespace], class_path, controller_file_name, "_form.html.erb"   )
        template "partial_list.html.erb",     File.join('app/views',options[:namespace], class_path, controller_file_name, "_list.html.erb"   )
        template "partial_show.html.erb",     File.join('app/views',options[:namespace], class_path, controller_file_name, "_show.html.erb"   )
        template "partial_edit.html.erb",     File.join('app/views',options[:namespace], class_path, controller_file_name, "_edit.html.erb"   )
        template "partial_bulk.html.erb",     File.join('app/views',options[:namespace], class_path, controller_file_name, "_bulk.html.erb"   )
        template "view_index.html.erb",       File.join('app/views',options[:namespace], class_path, controller_file_name, "index.html.erb"   )
        template "view_new.html.erb",         File.join('app/views',options[:namespace], class_path, controller_file_name, "new.html.erb"     )
        template "view_show.html.erb",        File.join('app/views',options[:namespace], class_path, controller_file_name, "show.html.erb"    )
        template "view_edit.html.erb",        File.join('app/views',options[:namespace], class_path, controller_file_name, "edit.html.erb"    )
        template "builder_index.xml.builder", File.join('app/views',options[:namespace], class_path, controller_file_name, "index.xml.builder")
        template "builder_index.xls.builder", File.join('app/views',options[:namespace], class_path, controller_file_name, "index.xls.builder")
        template "builder_index.pdf.prawn",   File.join('app/views',options[:namespace], class_path, controller_file_name, "index.pdf.prawn"  )
      end
      
      def add_header_menu_tab
        if options[:header]
          look_for = "<li><%= link_to '#{file_name.humanize}', '/admin/#{controller_file_name}', :class => (match_controller?('#{controller_file_name}'))  ? 'selected' : ''%>\n\t<ul class='sub'></ul></li>\n"
          gsub_file File.join('app/views/admin/shared', "_menu.html.erb"), look_for, ''
          append_file File.join('app/views/admin/shared', "_menu.html.erb"), look_for
        end
      end
      
      def create_locales_files
        # # Locales templates 
        options[:locales].each do |locale|
          template "locales_#{locale}.yml", File.join('config/locales', "#{controller_file_name}_#{locale}.yml")
        end
      end
      
      def add_resource_route
        route_config =  "namespace :#{namespace_name} do "
        route_config <<  class_path.collect{|namespace| "namespace :#{namespace} do " }.join(" ")
        route_config << "resources :#{file_name.pluralize}"
        route_config << " end" * class_path.size
        route_config << " end"
        route route_config
      end
      
      # Test Cases
      hook_for :test_framework, :as => :scaffold 
      
      protected 
      
      def namespace_class
        options[:namespace].classify
      end
      
      def namespace_name
        options[:namespace].underscore
      end
      
      # hook_for :template_engine, :test_framework, :as => :somatics_scaffold
      # Invoke the helper using the controller name (pluralized)
      # hook_for :helper, :as => :scaffold do |invoked|
      #         invoke invoked, [ controller_name ]
      #       end
      
      # # Controller, helper, views, test and stylesheets directories.
      # m.directory(File.join('app/models', class_path))
      # m.directory(File.join('app/controllers', controller_class_path))
      # m.directory(File.join('app/helpers', controller_class_path))
      # m.directory(File.join('app/views', controller_class_path, controller_file_name))
      # m.directory(File.join('app/views', controller_class_path, "shared"))
      # m.directory(File.join('test/functional', controller_class_path))
      # m.directory(File.join('test/unit', class_path))
      # m.directory(File.join('test/unit/helpers', controller_class_path))
      # m.directory(File.join('public/stylesheets', class_path))
      # m.directory(File.join('public/javascripts', class_path))
      # 
      # m.template 'controller.rb', File.join('app/controllers', controller_class_path, "#{controller_file_name}_controller.rb")
      # m.template 'helper.rb',     File.join('app/helpers',     controller_class_path, "#{controller_file_name}_helper.rb")
      # 
      # # Views and Builders
      # m.template "partial_form.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_form.html.erb")
      # m.template "partial_list.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_list.html.erb")
      # m.template "partial_show.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_show.html.erb")
      # m.template "partial_edit.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_edit.html.erb")
      # m.template "partial_bulk.html.erb", File.join('app/views', controller_class_path, controller_file_name, "_bulk.html.erb")
      # m.template "view_index.html.erb",   File.join('app/views', controller_class_path, controller_file_name, "index.html.erb")
      # m.template "view_new.html.erb",     File.join('app/views', controller_class_path, controller_file_name, "new.html.erb")
      # m.template "view_show.html.erb",    File.join('app/views', controller_class_path, controller_file_name, "show.html.erb")
      # m.template "view_edit.html.erb",    File.join('app/views', controller_class_path, controller_file_name, "edit.html.erb")
      # m.template "builder_index.xml.builder", File.join('app/views', controller_class_path, controller_file_name, "index.xml.builder")
      # m.template "builder_index.xls.builder", File.join('app/views', controller_class_path, controller_file_name, "index.xls.builder")
      # m.template "builder_index.pdf.prawn",   File.join('app/views', controller_class_path, controller_file_name, "index.pdf.prawn")
      # 
      # # Locales templates 
      # %w( en zh-TW ).each do |locale|
      #   m.template "locales_#{locale}.yml", File.join('config/locales', "#{controller_file_name}_#{locale}.yml")
      # end
      # 
      # # Application, Layout and Stylesheet and Javascript.
      # # m.template_without_destroy 'layout.html.erb', File.join('app/views/layouts', controller_class_path, "admin.html.erb"), :collision => :skip
      # # m.template_without_destroy 'application_helper.rb', File.join('app/helpers', controller_class_path, "admin_helper.rb"), :collision => :skip
      # # m.template_without_destroy 'partial_menu.html.erb', File.join('app/views', controller_class_path, "shared", "_menu.html.erb"), :collision => :skip
      # m.header_menu(controller_file_name) unless options[:no_header_menu]
      # # m.template_without_destroy 'context_menu.js', 'public/javascripts/context_menu.js', :collision => :skip
      # # m.template_without_destroy 'select_list_move.js', 'public/javascripts/select_list_move.js', :collision => :skip
      # # m.template('style.css', 'public/stylesheets/scaffold.css')
      # 
      # m.template('functional_test.rb', File.join('test/functional', controller_class_path, "#{controller_file_name}_controller_test.rb"))
      # m.template('helper_test.rb',     File.join('test/unit/helpers', controller_class_path, "#{controller_file_name}_helper_test.rb"))
      # 
      # m.admin_route_resources controller_file_name
      # 
      # if options[:admin_authenticated] || options[:authenticated]
      #   generate_sessions_controller(m)
      # else
      #   m.dependency 'model', [name] + @args, :collision => :skip 
      # end
      
    end
  end
end
