require 'generators/somatics'
require 'rails/generators/named_base'

module Somatics
  module Generators
    class AuthenticatedGenerator < Rails::Generators::NamedBase
      class_option :namespace, :banner => "NAME", :type => :string, :default => ''

      def create_devise_model
        invoke 'devise'
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
        invoke invoked, [name, "email:string", "name:string"]
        if File.exists?("app/models/#{singular_name}.rb")
          inject_into_file "app/models/#{singular_name}.rb", :after => "has_paper_trail :ignore => [:updated_at" do
            ", :encrypted_password, :password_salt, :reset_password_token, :remember_token, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip"
          end
        end           
      end
      
      def create_sessions_controller
        invoke 'somatics:authenticated_controller'
      end

      # include Rails::Generators::ResourceHelpers
      # include Rails::Generators::Migration
      # 
      # argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      # class_option :namespace, :banner => "NAME", :type => :string, :default => ''
      # 
      # class_option :skip_routes,          :type => :boolean, :desc => "Don't generate a resource line in config/routes.rb."
      # class_option :skip_migration,       :type => :boolean, :desc => "Don't generate a migration file for this model."
      # class_option :aasm,                 :type => :boolean, :desc => "Works the same as stateful but uses the updated aasm gem"
      # class_option :stateful,             :type => :boolean, :desc => "Builds in support for acts_as_state_machine and generatesactivation code."
      # class_option :rspec,                :type => :boolean, :desc => "Generate RSpec tests and Stories in place of standard rails tests."
      # class_option :old_passwords,        :type => :boolean, :desc => "Use the older password scheme"
      # class_option :include_activation,   :type => :boolean, :desc => "Skip the code for a ActionMailer and its respective Activation Code through email"
      # class_option :dump_generator_attrs, :type => :boolean, :desc => "Dump Generator Attrs"
      # 
      # 
      # def create_model_files
      #   template 'model.rb', File.join('app/models', class_path, "#{ file_name }.rb")
      #   if options.include_activation?
      #     # Check for class naming collisions.
      #     class_collisions  "#{class_name}Mailer", "#{class_name}MailerTest", "#{class_name}Observer"
      #     template "mailer.rb", File.join('app/mailers', class_path, "#{ file_name }_mailer.rb")
      #     template "observer.rb", File.join('app/models', class_path, "#{ file_name }_observer.rb")
      #   end
      # end
      # 
      # def add_model_and_migration
      #   unless options.skip_migration?
      #     migration_template 'migration.rb', "db/migrate/create_#{ migration_file_name }.rb"
      #   end
      # end
      # 
      # def dump_generator_attribute_names
      #   generator_attribute_names = [
      #     :table_name,
      #     :file_name,
      #     :class_name,
      #     :sessions_controller_name,
      #     :sessions_controller_class_path,
      #     :sessions_controller_file_path,
      #     # :sessions_controller_class_nesting,
      #     # :sessions_controller_class_nesting_depth,
      #     :sessions_controller_class_name,
      #     :sessions_controller_singular_name,
      #     :sessions_controller_plural_name,
      #     :sessions_controller_routing_name,                 # new_session_path
      #     :sessions_controller_routing_path,                 # /session/new
      #     :sessions_controller_controller_name,              # sessions
      #     :sessions_controller_file_name,
      #     :sessions_controller_table_name, 
      #     :controller_name,
      #     :controller_class_path,
      #     :controller_file_path,
      #     # :controller_class_nesting,
      #     # :controller_class_nesting_depth,
      #     # :controller_class_name,
      #     # :controller_singular_name,
      #     :controller_plural_name,
      #     :controller_routing_name,           # new_user_path
      #     # :controller_routing_path,           # /users/new
      #     # :controller_controller_name,        # users
      #     # :controller_file_name,  
      #     # :controller_singular_name,
      #     # :controller_table_name, 
      #     # :controller_plural_name,
      #   ]
      # 
      #   generator_attribute_names.each do |attr|
      #     puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
      #   end
      # 
      # end
      # 
      # # rails g authenticated FoonParent::Foon SporkParent::Spork -p --force --rspec --dump-generator-attrs
      # # table_name:                              foon_parent_foons
      # # file_name:                               foon
      # # class_name:                              FoonParent::Foon
      # # controller_name:                         SporkParent::Sporks
      # # controller_class_path:                   spork_parent
      # # controller_file_path:                    spork_parent/sporks
      # # controller_class_nesting:                SporkParent
      # # controller_class_nesting_depth:          1
      # # controller_class_name:                   SporkParent::Sporks
      # # controller_singular_name:                spork
      # # controller_plural_name:                  sporks
      # # controller_routing_name:                 spork
      # # controller_routing_path:                 spork_parent/spork
      # # controller_controller_name:              sporks
      # # controller_file_name:                    sporks
      # # controller_table_name:                   sporks
      # # controller_plural_name:                  sporks
      # # model_controller_name:                   FoonParent::Foons
      # # model_controller_class_path:             foon_parent
      # # model_controller_file_path:              foon_parent/foons
      # # model_controller_class_nesting:          FoonParent
      # # model_controller_class_nesting_depth:    1
      # # model_controller_class_name:             FoonParent::Foons
      # # model_controller_singular_name:          foons
      # # model_controller_plural_name:            foons
      # # model_controller_routing_name:           foon_parent_foons
      # # model_controller_routing_path:           foon_parent/foons
      # # model_controller_controller_name:        foons
      # # model_controller_file_name:              foons
      # # model_controller_singular_name:          foons
      # # model_controller_table_name:             foons
      # # model_controller_plural_name:            foons
      # 
      # 
      # protected 
      # 
      # def namespace_class
      #   # options[:namespace].classify
      # end
      # 
      # def namespace_name
      #   # options[:namespace].underscore
      # end
      # 
      # def sessions_controller_name
      #   file_name + '_sessions'
      # end
      # 
      # def sessions_controller_class_path
      #   class_path
      # end
      # 
      # def sessions_controller_file_path
      #   controller_file_path
      # end
      # 
      # def sessions_controller_singular_name
      #   controller_name
      # end
      # 
      # def sessions_controller_plural_name
      #   controller_name
      # end
      # 
      # def sessions_controller_routing_name  
      #   singular_name
      # end      
      # 
      # def sessions_controller_routing_path
      #   sessions_controller_file_path.singularize
      # end
      # 
      # def sessions_controller_class_name
      #   class_name + 'Session'
      # end
      # 
      # def sessions_controller_controller_name
      #   controller_plural_name
      # end
      # 
      # def sessions_controller_file_name
      #   file_name + '_session'
      # end
      # 
      # def sessions_controller_table_name
      #   controller_plural_name
      # end
      # 
      # def controller_plural_name
      #   plural_name
      # end
      # 
      # def controller_routing_name
      #   controller_plural_name
      # end
      # 
      # def migration_name
      #   "Create#{ class_name.pluralize.gsub(/::/, '') }"
      # end
      # 
      # def migration_file_name
      #   "#{ file_path.gsub(/\//, '_').pluralize }"
      # end
      # 
      # #
      # # Implement the required interface for Rails::Generators::Migration.
      # # taken from http://github.com/rails/rails/blob/master/activerecord/lib/generators/active_record.rb
      # #
      # def self.next_migration_number(dirname) #:nodoc:
      #   if ActiveRecord::Base.timestamped_migrations
      #     Time.now.utc.strftime("%Y%m%d%H%M%S")
      #   else
      #     "%.3d" % (current_migration_number(dirname) + 1)
      #   end
      # end
      # 
      # #
      # # !! These must match the corresponding routines in by_password.rb !!
      # #
      # def secure_digest(*args)
      #   Digest::SHA1.hexdigest(args.flatten.join('--'))
      # end
      # def make_token
      #   secure_digest(Time.now, (1..10).map{ rand.to_s })
      # end
      # def password_digest(password, salt)
      #   digest = $rest_auth_site_key_from_generator
      #   $rest_auth_digest_stretches_from_generator.times do
      #     digest = secure_digest(digest, salt, password, $rest_auth_site_key_from_generator)
      #   end
      #   digest
      # end
    end
  end
end
