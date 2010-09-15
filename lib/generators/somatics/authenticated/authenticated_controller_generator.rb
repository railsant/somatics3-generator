require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/resource_helpers'
require 'digest/sha1'
require 'rails/generators/migration'
        
module Somatics
  module Generators
    class AuthenticatedControllerGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::ResourceHelpers
      include Rails::Generators::Migration
      # hook_for :authenticated , :in => :somatics, :as => :scaffold, :default => 'somatics:scaffold' do |instance, command|
      #         instance.invoke command, [ class_name, attributes], {:namespace => 'admin' }
      # end
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :namespace, :banner => "NAME", :type => :string
      
      class_option :skip_routes,          :type => :boolean, :desc => "Don't generate a resource line in config/routes.rb."
      class_option :skip_migration,       :type => :boolean, :desc => "Don't generate a migration file for this model."
      class_option :aasm,                 :type => :boolean, :desc => "Works the same as stateful but uses the updated aasm gem"
      class_option :stateful,             :type => :boolean, :desc => "Builds in support for acts_as_state_machine and generatesactivation code."
      class_option :rspec,                :type => :boolean, :desc => "Generate RSpec tests and Stories in place of standard rails tests."
      class_option :old_passwords,        :type => :boolean, :desc => "Use the older password scheme"
      class_option :include_activation,   :type => :boolean, :desc => "Skip the code for a ActionMailer and its respective Activation Code through email"
      class_option :dump_generator_attrs, :type => :boolean, :desc => "Dump Generator Attrs"
      
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
      
      def create_controller_files
        template 'controller.rb', File.join('app/controllers',"#{options.namespace}", controller_class_path, "#{ controller_file_name }_controller.rb")
      end
      
      def generate_lib_files
        # Check for class naming collisions.
        class_collisions [], "#{class_name}AuthenticatedSystem", "#{class_name}AuthenticatedTestHelper"
        
        template 'authenticated_system.rb', File.join('lib', "#{controller_file_name}_authenticated_system.rb")
        template 'authenticated_test_helper.rb', File.join('lib', "#{controller_file_name}_authenticated_test_helper.rb")
      end
      
      def create_test_files
        #TODO : Create test files
      end
      
      def create_helper_files
        template 'session_helper.rb', File.join('app/helpers', sessions_controller_class_path, "#{ sessions_controller_file_name }_helper.rb")
        template 'helper.rb', File.join('app/helpers', controller_class_path, "#{ controller_file_name }_helper.rb")
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
        template 'login.html.erb', File.join('app/views', sessions_controller_file_name, 'new.html.erb')
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
      
      def dump_generator_attribute_names
        generator_attribute_names = [
          :namespace_class,
          :namespace_name,          
          :table_name,
          :file_name,
          :class_name,
          :sessions_controller_name,
          :sessions_controller_class_path,
          :sessions_controller_file_path,
          # :sessions_controller_class_nesting,
          # :sessions_controller_class_nesting_depth,
          :sessions_controller_class_name,
          :sessions_controller_singular_name,
          :sessions_controller_plural_name,
          :sessions_controller_routing_name,                 # new_session_path
          :sessions_controller_routing_path,                 # /session/new
          :sessions_controller_controller_name,              # sessions
          :sessions_controller_file_name,
          :sessions_controller_table_name, 
          :controller_name,
          :controller_class_path,
          :controller_file_path,
          # :controller_class_nesting,
          # :controller_class_nesting_depth,
          # :controller_class_name,
          # :controller_singular_name,
          :controller_plural_name,
          :controller_routing_name,           # new_user_path
          # :controller_routing_path,           # /users/new
          # :controller_controller_name,        # users
          # :controller_file_name,  
          # :controller_singular_name,
          # :controller_table_name, 
          # :controller_plural_name,
        ]

        generator_attribute_names.each do |attr|
          puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
        end

      end
      
      # rails g authenticated FoonParent::Foon SporkParent::Spork -p --force --rspec --dump-generator-attrs
      # table_name:                              foon_parent_foons
      # file_name:                               foon
      # class_name:                              FoonParent::Foon
      # controller_name:                         SporkParent::Sporks
      # controller_class_path:                   spork_parent
      # controller_file_path:                    spork_parent/sporks
      # controller_class_nesting:                SporkParent
      # controller_class_nesting_depth:          1
      # controller_class_name:                   SporkParent::Sporks
      # controller_singular_name:                spork
      # controller_plural_name:                  sporks
      # controller_routing_name:                 spork
      # controller_routing_path:                 spork_parent/spork
      # controller_controller_name:              sporks
      # controller_file_name:                    sporks
      # controller_table_name:                   sporks
      # controller_plural_name:                  sporks
      # model_controller_name:                   FoonParent::Foons
      # model_controller_class_path:             foon_parent
      # model_controller_file_path:              foon_parent/foons
      # model_controller_class_nesting:          FoonParent
      # model_controller_class_nesting_depth:    1
      # model_controller_class_name:             FoonParent::Foons
      # model_controller_singular_name:          foons
      # model_controller_plural_name:            foons
      # model_controller_routing_name:           foon_parent_foons
      # model_controller_routing_path:           foon_parent/foons
      # model_controller_controller_name:        foons
      # model_controller_file_name:              foons
      # model_controller_singular_name:          foons
      # model_controller_table_name:             foons
      # model_controller_plural_name:            foons
      
      
      protected 
      
      def namespace_class
        options[:namespace].classify
      end
      
      def namespace_name
        options[:namespace].underscore
      end
      
      def sessions_controller_name
        file_name + '_sessions'
      end
      
      def sessions_controller_class_path
        class_path
      end
      
      def sessions_controller_file_path
        file_name + '_sessions'
      end
      
      def sessions_controller_singular_name
        sessions_controller_file_name
      end
      
      def sessions_controller_plural_name
        sessions_controller_file_name.pluralize
      end
      
      def sessions_controller_routing_name  
        sessions_controller_plural_name
      end      
      
      def sessions_controller_routing_path
        sessions_controller_file_path.singularize
      end
      
      def sessions_controller_class_name
        class_name + 'Session'
      end
      
      def sessions_controller_controller_name
        sessions_controller_plural_name
      end
      
      def sessions_controller_file_name
        file_name + '_session'
      end
      
      def sessions_controller_table_name
        sessions_controller_plural_name
      end
      
      def controller_plural_name
        plural_name
      end
      
      def controller_routing_name
        controller_plural_name
      end
      
      def migration_name
        "Create#{ class_name.pluralize.gsub(/::/, '') }"
      end

      def migration_file_name
        "#{ file_path.gsub(/\//, '_').pluralize }"
      end
      
      #
      # Implement the required interface for Rails::Generators::Migration.
      # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
      #
      def self.next_migration_number(dirname) #:nodoc:
        if ActiveRecord::Base.timestamped_migrations
          Time.now.utc.strftime("%Y%m%d%H%M%S")
        else
          "%.3d" % (current_migration_number(dirname) + 1)
        end
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
