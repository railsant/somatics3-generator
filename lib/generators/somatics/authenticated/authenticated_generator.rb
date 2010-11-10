require 'generators/somatics'
require 'rails/generators/named_base'

module Somatics
  module Generators
    class AuthenticatedGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      class_option :namespace, :banner => "NAME", :type => :string, :default => ''
      class_option :locales, :type => :array, :banner => "LOCALE LOCALE", :default => %w( en zh-TW ),
                             :desc => "Supported Locales"

      def create_devise_model
        invoke 'devise'
      end
      
      def modify_devise_validation
        if File.exists?("app/models/#{singular_name}.rb")
          inject_into_file "app/models/#{singular_name}.rb", :before => "  # Setup accessible" do
            <<-RUBY
  def password_required?
    return false if !new_record? && password.blank? && password_confirmation.blank?
    super
  end

            RUBY
          end
        end
      end
      
      def add_fields_to_devise_model
        invoke "migration", [%(add_name_to_#{table_name}), "name:string"]
        if File.exists?("app/models/#{singular_name}.rb")
          inject_into_file "app/models/#{singular_name}.rb", :after => ":remember_me" do
            ", :name"
          end
        end
      end

      hook_for :scaffold_controller do |invoked|
        invoke invoked, [name, "email:string", "name:string"], :namespace => 'admin'
        if File.exists?("app/models/#{singular_name}.rb")
          inject_into_file "app/models/#{singular_name}.rb", :after => "has_paper_trail :ignore => [:updated_at" do
            ", :encrypted_password, :password_salt, :reset_password_token, :remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip"
          end
        end           
      end
      
      def modify_devise_model_form
        template "partial_form.html.erb", File.join('app/views', 'admin', class_path, plural_name, "_form.html.erb"), :force => true
      end
      
      def create_sessions_controller
        invoke 'somatics:authenticated_controller'
      end

      def modify_devise_route
        inject_into_file File.join('config/routes.rb'), :after => "devise_for :#{table_name}" do
          session_controller = ((options.namespace.blank? ? [] : [options.namespace]) << "#{name}_sessions").join('/')
          ", :path => '#{options.namespace}', :controllers => {:sessions => '#{session_controller}'}"
        end
      end

    end
  end
end
