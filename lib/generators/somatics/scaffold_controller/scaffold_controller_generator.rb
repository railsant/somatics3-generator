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
      class_option :skip_auditing, :type => :boolean, :default => false, :desc => "Don't generate auditing information."

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
      
      def inject_somatics_filters
        filters = ["  has_filter :id, :integer, :default => true\n", "  has_filter :created_at, :date\n"]
        filters |= attributes.collect do |attribute|
          "  has_filter :#{attribute.name}, :#{attribute.type}\n"
        end
        # FIXME The model generator removes the model.rb already
        if File.exists?("app/models/#{singular_name}.rb")
          inject_into_class "app/models/#{singular_name}.rb", class_name, filters.join('')
          inject_into_class "app/models/#{singular_name}.rb", class_name,
<<-RUBY
  # Somatics Filter (Reference: http://github.com/inspiresynergy/somatics_filter)
RUBY
        end
      end
      
      def inject_paper_trail
        unless options[:skip_auditing]
          # FIXME The model generator removes the model.rb already
          if File.exists?("app/models/#{singular_name}.rb")
            inject_into_class "app/models/#{singular_name}.rb", class_name, "  has_paper_trail :ignore => [:updated_at]\n"
          end
        end
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
    end
  end
end
