require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/migration'

module Somatics
  module Generators
    class AttributesGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::Migration
      # include Rails::Generators::ResourceHelpers
       
       def dump_generator_attribute_names
          generator_attribute_names = [
            :name,
            :singular_name,
            :human_name,
            :plural_name,
            :relationship,
            :model_name,
            :class_name,
            :reference_model_name,
            :reference_class_name,
            :reference_value, 
            :migration_model_name,
            :migration_table_name,
            :migration_attribute ,
            :table_name

          ]
       
          generator_attribute_names.each do |attr|
            puts "%-40s %s" % ["#{attr}:", self.send(attr.to_s)]  # instance_variable_get("@#{attr.to_s}"
          end
       
        end
        
        def add_relationship_to_model
          relation = "has_many :#{reference_value}"
          sentinel = "class #{class_name} < ActiveRecord::Base\n"
          gsub_file File.join('app/models', "#{model_name}.rb"), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}  #{relation}\n"
          end
          # logger.insert relation
          relation = "belongs_to :#{model_name}"
          sentinel = "class #{reference_class_name} < ActiveRecord::Base\n"
          gsub_file File.join('app/models', "#{reference_model_name}.rb"), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}  #{relation}\n"
          end
          # logger.insert relation
        end
        
        def add_show_view_to_model_show
          sentinel = "<!-- More List View -->\n"
          reference_list = <<-CODE
      <% if @#{reference_model_name}.#{model_name} %>
      <h3><%=link_to "\#{#{class_name}.human_name} #\#{@#{reference_model_name}.#{model_name}.id}", [:admin, @#{reference_model_name}.#{model_name}] %></h3>
      <div class="issue detail">
      	<%= render :partial => 'admin/#{model_name.pluralize}/show' , :locals => {:#{model_name} => @#{reference_model_name}.#{model_name}} %>
      </div>
      <% end %>
          CODE
          gsub_file File.join('app/views/admin', reference_model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}#{reference_list}"
          end
          # logger.update File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
          gsub_file File.join('app/views/admin', reference_model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}#{reference_list}"
          end
          # logger.update File.join('app/views/admin', reference_model_name.pluralize, 'edit.html.erb')
        end

        def add_list_view_to_model_show
          sentinel = "<!-- More List View -->\n"
          reference_list = <<-CODE
      <div class="contextual">
        <%= link_to "\#{t 'Add'} \#{#{reference_class_name}.human_name}", '#', :class => "icon icon-add", :onclick => "showAndScrollTo('add_#{reference_model_name}','focus_#{reference_model_name}'); return false;"%>
      </div>
      <h3><%=#{reference_class_name}.human_name%></h3>
      <% @#{reference_value} = @#{model_name}.#{reference_value}.paginate(:page => params[:#{reference_model_name}_page], :order => (params[:#{reference_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{reference_model_name}_sort].blank?))%>
      <div class="autoscroll">
        <%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{reference_value}} %>
      </div>
      <%= will_paginate @#{reference_value}, :renderer => SomaticLinkRenderer %>
      <div id="add_#{reference_model_name}" style="display:none">
        <h3><%= "\#{t('New')} \#{#{reference_class_name}.human_name}" %></h3>
        <div id="focus_#{reference_model_name}"></div>
        <% form_for([:admin, @#{model_name}.#{reference_value}.build]) do |f| %>
          <%= f.error_messages %>
          <div class="issue">
            <%= render :partial => 'admin/#{reference_value}/form' , :locals => {:f => f} %>
          </div>
          <%= hidden_field_tag :return_to, url_for%>
          <%= f.submit t('Create') %>
        <% end %>
        <%= link_to_function t('Cancel'), "$('add_#{reference_model_name}').hide()"%>
      </div>
      CODE
          gsub_file File.join('app/views/admin', model_name.pluralize, 'show.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}#{reference_list}"
          end
          # logger.update File.join('app/views/admin', model_name.pluralize, 'show.html.erb')
          gsub_file File.join('app/views/admin', model_name.pluralize, 'edit.html.erb'), /(#{Regexp.escape(sentinel)})/mi do |match|
            "#{match}#{reference_list}"
          end
          # logger.update File.join('app/views/admin', model_name.pluralize, 'edit.html.erb')
        end
        
        def migrations
          if relationship == 'has_many'
            
            #TODO :  dependency 'admin_attributes', [migration_model_name, "#{migration_attribute}:integer"], :skip_migration => true unless options[:skip_views]
            # raise 'migration_exists' if m.migration_exists?("add_#{migration_attribute}_to_#{migration_table_name}")
            unless options[:skip_migration] 
              migration_template 'migration.rb', "db/migrate/add_#{migration_attribute}_to_#{migration_table_name}"
            end
          end
        end

        
        protected 
        
        def match_data
          @match_data ||= name.match(/(.*)_(has_many|belongs_to)_(.*)/)
        end
        
        def relationship
          match_data[2]
        end
        
        def model_name
          match_data[1].singularize
        end
        
        def class_name
          model_name.classify
        end
        
        def reference_model_name
          match_data[3].singularize
        end
        
        def reference_class_name
          reference_model_name.classify
        end
        
        def reference_value
          reference_model_name.pluralize
        end
        
        def migration_table_name
          reference_value
        end
        
        def migration_model_name
          reference_model_name
        end
        
        def migration_attribute
          "#{model_name}_id"
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
        
        def legacy_functions
          raise banner unless match_data = @command.match(/(.*)_(has_many|belongs_to)_(.*)/)
          @relationship = match_data[2]
          @model_name = match_data[1].singularize
          @class_name = @model_name.camelize
          @reference_model_name = match_data[3].singularize
          @reference_class_name = @reference_model_name.camelize
          case @relationship
            when 'has_many'
              @reference_value = @reference_model_name.pluralize
              @migration_model_name = @reference_model_name
              @migration_table_name = @reference_value
              @migration_attribute = "#{@model_name}_id"
            when 'belongs_to'
              # @reference_value = @reference_model_name
              # @migration_model_name = @model_name
              # @migration_table_name = @model_name.pluralize
              # @migration_attribute = "#{@reference_model_name}_id"
          end
        end
        
    end
  end
end
