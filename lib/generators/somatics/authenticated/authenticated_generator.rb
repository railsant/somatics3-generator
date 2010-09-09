require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
require 'digest/sha1'
        
module Somatics
  module Generators
    class AuthenticatedGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::ResourceHelpers
      # hook_for :authenticated , :in => :somatics, :as => :scaffold, :default => 'somatics:scaffold' do |instance, command|
      #         instance.invoke command, [ class_name, attributes], {:namespace => 'admin' }
      # end
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :namespace, :banner => "NAME", :type => :string, :required => false, :default => "admin"
      class_option :include_activation, :type => :boolean, :required => false, :default => false
      class_option :old_passwords, :type => :boolean, :required => false, :default => false
      
      # Try to be idempotent:
      # pull in the existing site key if any,
      # seed it with reasonable defaults otherwise
      #
      def load_or_initialize_site_keys
        case
        when defined? REST_AUTH_SITE_KEY
          if (options[:old_passwords]) && ((! REST_AUTH_SITE_KEY.blank?) || (REST_AUTH_DIGEST_STRETCHES != 1))
            raise "You have a site key, but --old-passwords will overwrite it.  If this is really what you want, move the file #{site_keys_file} and re-run."
          end
          $rest_auth_site_key_from_generator         = REST_AUTH_SITE_KEY
          $rest_auth_digest_stretches_from_generator = REST_AUTH_DIGEST_STRETCHES
        when options[:old_passwords]
          $rest_auth_site_key_from_generator         = nil
          $rest_auth_digest_stretches_from_generator = 1
          $rest_auth_keys_are_new                    = true
        else
          $rest_auth_site_key_from_generator         = make_token
          $rest_auth_digest_stretches_from_generator = 10
          $rest_auth_keys_are_new                    = true
        end
        # template 'config/initializers/site_keys.rb', "config/initializers/#{controller_file_name}_site_keys.rb"
        template 'config/initializers/site_keys.rb'
      end
      
      def generate_authentication_system
        # Check for class naming collisions.
        class_collisions [], "#{class_name}AuthenticatedSystem", "#{class_name}AuthenticatedTestHelper"
        
        template 'authenticated_system.rb', File.join('lib', "#{controller_file_name}_authenticated_system.rb")
        template 'authenticated_test_helper.rb', File.join('lib', "#{controller_file_name}_authenticated_test_helper.rb")
      end
      
      def generate_observer
        # Check for class naming collisions.
        class_collisions  "#{class_name}Mailer", "#{class_name}MailerTest", "#{class_name}Observer"
        
        if options[:include_activation]
          %w( mailer observer ).each do |model_type|
            template "#{model_type}.rb", File.join('app/models', class_path, "#{file_name}_#{model_type}.rb")
          end
          # template 'test/mailer_test.rb', File.join('test/unit', class_path, "#{file_name}_mailer_test.rb") if options[:include_activation]
        end
      end
      
      def generate_sessions_controller

        # Check for class naming collisions.
        class_collisions sessions_controller_class_path, "#{sessions_controller_class_name}Controller", # Sessions Controller
                                                         "#{sessions_controller_class_name}Helper"

        template 'sessions_controller.rb', File.join('app/controllers', sessions_controller_class_path, "#{sessions_controller_file_name}_controller.rb")
        # template 'session_helper.rb', File.join('app/helpers', sessions_controller_class_path, "#{sessions_controller_file_name}_helper.rb")
        # template 'test/sessions_functional_test.rb', File.join('test/functional', sessions_controller_class_path, "#{sessions_controller_file_name}_controller_test.rb")

        # View templates
        # template 'login.html.erb',  File.join('app/views', sessions_controller_class_path, sessions_controller_file_name, "new.html.erb")
        template 'login.html.erb', File.join('app/views', controller_file_name, 'new.html.erb')
        # template 'signup.html.erb', File.join('app/views', controller_class_path, controller_file_name, "signup.html.erb")
        template 'signup.html.erb', File.join('app/views', controller_file_name, 'new.html.erb')
        # template '_model_partial.html.erb', File.join('app/views', controller_class_path, controller_file_name, "_#{file_name}_bar.html.erb")
        template '_model_partial.html.erb', File.join('app/views', controller_file_name, "_#{file_name}_bar.html.erb")

        unless options[:skip_routes]
          # signup routes
          route %Q{match '#{file_name}_signup' => '#{controller_plural_name}#new'}
          route %Q{match '#{file_name}_register' => '#{controller_plural_name}#create'}
          # login 
          route %Q{match '#{file_name}_login' => '#{sessions_controller_controller_name}#new'}
          # logout 
          route %Q{match '#{file_name}_logout' => '#{sessions_controller_controller_name}#destroy'}
        end
      end
      
      def insert_into_application_controller
        puts "TODO: include #{class_name}AuthenticatedSystem"
      end
      
      def add_model_and_migration
        template 'model.rb', "app/model/#{singular_name}.rb"
        template 'migration.rb', "app/model/#{singular_name}.rb"
      end
      
      private 
      
      def namespace_class
        options[:namespace].classify
      end
      
      def namespace_name
        options[:namespace].underscore
      end
      
      def sessions_controller_class_path
        controller_class_path
      end
      
      def sessions_controller_class_name
        controller_class_name
      end
      
      def sessions_controller_file_name
        controller_file_name
      end
      
      def sessions_controller_name
        controller_name
      end
      
      def sessions_controller_routing_name  
        singular_name
      end
      
      def sessions_controller_routing_path
        controller_file_path.singularize
      end
      
      def sessions_controller_controller_name
        controller_plural_name
      end
      
      def controller_plural_name
        plural_name
      end
      
      #
      # !! These must match the corresponding routines in by_password.rb !!
      #
      def secure_digest(*args)
        Digest::SHA1.hexdigest(args.flatten.join('--'))
      end
      def make_token
        secure_digest(Time.now, (1..10).map{ rand.to_s })
      end
      def password_digest(password, salt)
        digest = $rest_auth_site_key_from_generator
        $rest_auth_digest_stretches_from_generator.times do
          digest = secure_digest(digest, salt, password, $rest_auth_site_key_from_generator)
        end
        digest
      end
    end
  end
end
