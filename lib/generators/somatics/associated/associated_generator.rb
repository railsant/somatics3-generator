require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/migration'

require 'net/http'
require 'uri'
require 'json'
class GoogleTranslate
  def self.t(text,to_lang = 'zh-TW')
    uri = URI.parse('http://ajax.googleapis.com/ajax/services/language/translate')
    JSON.parse(Net::HTTP.post_form(uri, {"q" => text, "langpair" => "en|#{to_lang}", "v" => '1.0'}).body)['responseData']['translatedText'] rescue text.humanize
  end
end


module Somatics
  module Generators
    class AssociatedGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::Migration
      include Rails::Generators::ResourceHelpers
      
      argument :associated_field, :type => :string, :banner => 'associated_field_name'
      argument :attribute, :type => :hash, :default => {"name" => "string"}, :banner => "field:type"
      # argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
      class_option :namespace, :banner => "NAME", :type => :string, :default => 'admin'
      class_option :skip_migration,       :type => :boolean, :desc => "Don't generate a migration file for this model."
      class_option :locales, :type => :array, :banner => "LOCALE LOCALE", :default => %w( en zh-TW ),
                             :desc => "Supported Locales"

       
       def dump_generator_attribute_names
          generator_attribute_names = [
            :name,
            :singular_name,
            :human_name,
            :plural_name,
            :table_name,
            :class_name,
            :controller_class_path,
            :controller_file_name,
            :attribute_name,
            :attribute_type,
            :associated_name,
            :associated_singular_name, 
            :associated_human_name, 
            :associated_plural_name, 
            :associated_table_name,
            :associated_class_name,
          ]
       
          generator_attribute_names.each do |attr|
            # puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
          end
       
        end
        
        def generate_associated_scaffold
          invoke 'somatics:scaffold', [associated_class_name, "#{attribute_name}:#{attribute_type}"], {:namespace => options[:namespace], :header => false }                    
        end
        
        def update_menu
          # add attributes type to submenu
          # look_for = /<li ><%= link_to 'Product', '\/admin\/products', :class => (match_controller?('products'))  \? 'selected' : ''%>.*<ul>/
          look_for = /<%=.*\/#{options.namespace}\/#{plural_name}.*%>[^<]*<ul[^>]*>/
          inject_into_file File.join('app/views/',options.namespace, 'shared/_menu.html.erb'), :after => look_for do 
            <<-RUBY
            
              <li><%=link_to #{class_name}.human_attribute_name(:#{associated_name}), '/#{options.namespace}/#{associated_plural_name}' %></li>
            RUBY
          end
          
        end
        
        def update_show_partial
          look_for = "</tbody>\n</table>"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_show.html.erb'), :before => look_for do
              "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{associated_name}) %></b></td>\n    <td><%=h #{singular_name}.#{associated_name}_#{attribute_name}%></td>\n  </tr>\n"
          end
        end 

        def update_form_partial
          look_for = "</tbody>\n</table>"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_form.html.erb'), :before => look_for do 
            "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{associated_name}) %></b></td>\n    <td><%= f.collection_select :#{associated_name}_id, #{associated_class_name}.all, :id, :#{attribute_name}, :prompt => true %></td>\n  </tr>\n"
          end
        end
        
        def update_list_partial
          # look_for = "      <!-- More Sort Link Helper -->"
          # inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_list.html.erb'), :after => look_for do
          #   "      <th title=\"Sort by &quot;#{attribute.name.humanize}&quot;\"><%= sort_link_helper #{class_name}.human_attribute_name(:#{attribute.name}), '#{singular_name}', '#{attribute.name}' %></th>\n"
          # end
          # look_for = "      <!-- More Fields -->"
          # inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_list.html.erb'), :after => look_for do 
          #   "      <td onclick=\"link_to(<%= \"'\#{admin_#{singular_name}_path(#{singular_name})}'\" %>);\" class=\"#{attribute.name}\"><%=h #{singular_name}.#{attribute.name} %></td>\n"
          # end
        end
        
        def add_attribute_to_locales
          options[:locales].each do |locale|
            append_file File.join('config/locales', "#{controller_file_name}_#{locale}.yml") do
                "        #{associated_name}: #{GoogleTranslate.t associated_human_name, locale}\n"
            end
          end
        end
        
        def add_association_to_model
          inject_into_class "app/models/#{name}.rb", class_name do 
            <<-RUBY
            belongs_to :#{associated_name}
            def #{associated_name}_#{attribute_name} 
              self.#{associated_name}.#{attribute_name} unless self.#{associated_name}.blank?
            end

            def #{associated_name}_#{attribute_name}=(#{associated_name}_#{attribute_name}) 
              self.#{associated_name} = #{associated_class_name}.find_by_#{attribute_name}(#{associated_name}_#{attribute_name}) || #{associated_class_name}.new(:#{attribute_name} => #{associated_name}_#{attribute_name})
            end
            RUBY
          end
          
          inject_into_class "app/models/#{associated_name}.rb", associated_class_name do 
            <<-RUBY
              has_many :#{class_name}
            RUBY
          end rescue nil
        end
        
        def migrate_attributes
          unless options[:skip_migration]
            invoke "migration", [%(add_#{associated_singular_name}_to_#{table_name}), "#{associated_singular_name}_id:integer"]
          end
        end
        
        protected 
        
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
        
        private 
        def attribute_name
          attribute.keys.first
        end
        
        def attribute_type
          attribute.values.first
        end
        
        def associated_name
          name + '_' + associated_field
        end
        
        def associated_singular_name
          associated_name.singularize
        end
        
        def associated_human_name
          associated_name.humanize
        end
        
        def associated_plural_name
          associated_name.pluralize
        end
        
        def associated_table_name
          associated_name.tableize
        end
        
        def associated_class_name
          associated_name.classify
        end
        
    end
  end
end
