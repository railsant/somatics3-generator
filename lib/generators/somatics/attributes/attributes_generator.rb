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
    class AttributesGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::Migration
      include Rails::Generators::ResourceHelpers
      
      argument :attributes, :type => :array, :default => [], :banner => "field:type field:type"
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
            :attributes,
            :class_name,
            :controller_class_path,
            :controller_file_name,
          ]
       
          generator_attribute_names.each do |attr|
            # puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
          end
       
        end
        def update_show_partial
          look_for = "</tbody>\n</table>"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_show.html.erb'), :before => look_for do
            attributes.inject('') do |str, attribute|
              "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{attribute.name}) %></b></td>\n    <td><%=h #{singular_name}.#{attribute.name} %></td>\n  </tr>\n"
            end
          end
        end 

        def update_form_partial
          look_for = "</tbody>\n</table>"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_form.html.erb'), :before => look_for do 
            attributes.inject('') do |str, attribute|
              "  <tr>\n    <td><b><%= #{class_name}.human_attribute_name(:#{attribute.name}) %></b></td>\n    <td><%= f.#{attribute.field_type} :#{attribute.name} %></td>\n  </tr>\n"
            end
          end
        end
        
        def update_list_partial
          look_for = "      <!-- More Sort Link Helper -->"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_list.html.erb'), :after => look_for do
            attributes.inject('') do |str, attribute|
              str + "      <th title=\"Sort by &quot;#{attribute.name.humanize}&quot;\"><%= sort_link_helper #{class_name}.human_attribute_name(:#{attribute.name}), '#{singular_name}', '#{attribute.name}' %></th>\n"
            end
          end
          look_for = "      <!-- More Fields -->"
          inject_into_file File.join('app/views/',options.namespace, controller_class_path, controller_file_name, '_list.html.erb'), :after => look_for do 
            result = attributes.inject('') do |str, attribute|
              str + "      <td onclick=\"link_to(<%= \"'\#{admin_#{singular_name}_path(#{singular_name})}'\" %>);\" class=\"#{attribute.name}\"><%=h #{singular_name}.#{attribute.name} %></td>\n"
            end
          end
        end
        
        def update_locales
          options[:locales].each do |locale|
            append_file File.join('config/locales', "#{controller_file_name}_#{locale}.yml") do
              attributes.inject('') do |str, attribute|
                "        #{attribute.name}: #{GoogleTranslate.t attribute.name.humanize, locale}\n"
              end
            end
          end
        end
        
        def migrate_attributes
          unless options[:skip_migration]
            migration_name = attributes.collect(&:name).join('_and_')
            invoke "migration", [%(add_#{migration_name}_to_#{table_name}), attributes.collect{|a| "#{a.name}:#{a.type}"}]
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
        
    end
  end
end
