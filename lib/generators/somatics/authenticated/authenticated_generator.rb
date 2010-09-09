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
      end
      
      def generate_sessions_controller
        puts sessions_controller_file_name
        puts 'csessions_controller_file_name'
        # Check for class naming collisions.
        class_collisions sessions_controller_class_path, "#{sessions_controller_class_name}Controller", # Sessions Controller
                                                         "#{sessions_controller_class_name}Helper"
        class_collisions                                 "#{class_name}Mailer", "#{class_name}MailerTest", "#{class_name}Observer"
        class_collisions [], "#{class_name}AuthenticatedSystem", "#{class_name}AuthenticatedTestHelper"

        # template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
        # if options[:include_activation]
        #           %w( mailer observer ).each do |model_type|
        #             template "#{model_type}.rb", File.join('app/models', class_path, "#{file_name}_#{model_type}.rb")
        #           end
        #         end

        template 'sessions_controller.rb', File.join('app/controllers', sessions_controller_class_path, "#{sessions_controller_file_name}_controller.rb")

        template 'authenticated_system.rb', File.join('lib', "#{controller_file_name}_authenticated_system.rb")
        template 'authenticated_test_helper.rb', File.join('lib', "#{controller_file_name}_authenticated_test_helper.rb")
        template 'config/initializers/site_keys.rb', "config/initializers/#{controller_file_name}_site_keys.rb"

        # template 'test/sessions_functional_test.rb', File.join('test/functional', sessions_controller_class_path, "#{sessions_controller_file_name}_controller_test.rb")
        # template 'test/mailer_test.rb', File.join('test/unit', class_path, "#{file_name}_mailer_test.rb") if options[:include_activation]
        # template 'test/unit_test.rb', File.join('test/unit', class_path, "#{file_name}_test.rb")

        # template 'test/users.yml', File.join('test/fixtures', class_path, "#{table_name}.yml")                            
        # template 'session_helper.rb', File.join('app/helpers', sessions_controller_class_path, "#{sessions_controller_file_name}_helper.rb")

        # View templates
        # template 'login.html.erb',  File.join('app/views', sessions_controller_class_path, sessions_controller_file_name, "new.html.erb")
        # template 'signup.html.erb', File.join('app/views', controller_class_path, controller_file_name, "signup.html.erb")
        # template '_model_partial.html.erb', File.join('app/views', controller_class_path, controller_file_name, "_#{file_name}_bar.html.erb")

        # if options[:include_activation]
        #           # Mailer templates
        #           %w( activation signup_notification ).each do |action|
        #             template "#{action}.erb", File.join('app/views', "#{file_name}_mailer", "#{action}.erb")
        #           end
        #         end

        unless options[:skip_migration]
          # migration_template 'migration.rb', 'db/migrate', :assigns => {
          #   :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
          # }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
        end

        unless options[:skip_routes]
          
          
          
          # if options[:admin_authenticated]
          #   # Note that this fails for nested classes -- you're on your own with setting up the routes.
          #   admin_route_resource  sessions_controller_singular_name
          #   admin_route_name("#{file_name}_signup",   "/#{controller_plural_name}/signup",   {:controller => controller_plural_name, :action => 'signup'})
          #   admin_route_name("#{file_name}_register", "/#{controller_plural_name}/register", {:controller => controller_plural_name, :action => 'register'})
          #   admin_route_name("#{file_name}_login",    "/#{controller_plural_name}/login",    {:controller => sessions_controller_controller_name, :action => 'new'})
          #   admin_route_name("#{file_name}_logout",   "/#{controller_plural_name}/logout",   {:controller => sessions_controller_controller_name, :action => 'destroy'})
          # else 
          #   # Note that this fails for nested classes -- you're on your own with setting up the routes.
          #   template 'controller.rb', File.join('app/controllers', "#{controller_class_name}_controller.rb")
          #   template 'helper.rb', File.join('app/helpers', "#{controller_class_name}_helper.rb")
          #   # directory File.join('app/views', controller_file_name)
          #   template 'signup.html.erb', File.join('app/views', controller_file_name, "new.html.erb")
          #   template '_model_partial.html.erb', File.join('app/views', controller_file_name, "_#{file_name}_bar.html.erb")
          #   # route_resource  sessions_controller_singular_name
          #   route_name("#{file_name}_signup",   "/#{controller_class_name}/signup",    {:controller => controller_plural_name, :action => 'new'})
          #   route_name("#{file_name}_register", "/#{controller_class_name}/register",  {:controller => controller_plural_name, :action => 'create'})
          #   route_name("#{file_name}_login",    "/#{controller_class_name}/login",    {:controller => sessions_controller_controller_name, :action => 'new'})
          #   route_name("#{file_name}_logout",   "/#{controller_class_name}/logout",    {:controller => sessions_controller_controller_name, :action => 'destroy'})
          # end
        end   
        
        template '_model_partial.html.erb', File.join('app/views', controller_file_name, "_#{file_name}_bar.html.erb")
        
        # signup view and routes
        template 'signup.html.erb', File.join('app/views', controller_file_name, 'new.html.erb')
        route %Q{match '#{file_name}_signup' => '#{controller_plural_name}#new'}
        route %Q{match '#{file_name}_register' => '#{controller_plural_name}#create'}
        
        # login 
        template 'login.html.erb', File.join('app/views', controller_file_name, 'new.html.erb')
        route %Q{match '#{file_name}_login' => '#{sessions_controller_controller_name}#new'}
        
        # logout 
        route %Q{match '#{file_name}_logout' => '#{sessions_controller_controller_name}#destroy'}
                          
      end
      
      private 
      
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
