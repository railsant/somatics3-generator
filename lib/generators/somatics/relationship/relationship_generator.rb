require 'generators/somatics'
require 'rails/generators/named_base'
require 'rails/generators/migration'

module Somatics
  module Generators
    class RelationshipGenerator < Rails::Generators::NamedBase
      extend TemplatePath
      include Rails::Generators::Migration
      # include Rails::Generators::ResourceHelpers
      class_option :skip_migration,       :type => :boolean, :desc => "Don't generate a migration file for this model."
      class_option :namespace, :banner => "NAME", :type => :string, :default => 'admin'
      
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
          relation = "  has_many :#{reference_value}\n"
          # sentinel = "class #{class_name} < ActiveRecord::Base\n"
          inject_into_class "app/models/#{model_name}.rb", class_name, relation

          relation = "  belongs_to :#{model_name}\n"
          # sentinel = "class #{reference_class_name} < ActiveRecord::Base\n"
          inject_into_class "app/models/#{reference_model_name}.rb",reference_class_name, relation

        end
        
        def add_show_view_to_model_show
          sentinel = "<!-- More List View -->\n"
          reference_list = <<-CODE
      <% if @#{reference_model_name}.#{model_name} %>
      <h3><%=link_to "\#{#{class_name}.model_name.human} #\#{@#{reference_model_name}.#{model_name}.id}", [:admin, @#{reference_model_name}.#{model_name}] %></h3>
      <div class="issue detail">
      	<%= render :partial => 'admin/#{model_name.pluralize}/show' , :locals => {:#{model_name} => @#{reference_model_name}.#{model_name}} %>
      </div>
      <% end %>
          CODE
          inject_into_file File.join('app/views',options[:namespace], reference_model_name.pluralize, 'show.html.erb'), :after => sentinel do 
            "#{reference_list}"
          end
          
          inject_into_file File.join('app/views',options[:namespace], reference_model_name.pluralize, 'edit.html.erb'), :after => sentinel do
            "#{reference_list}"
          end
        end

        def add_list_view_to_model_show
          sentinel = "<!-- More List View -->\n"
          reference_list = <<-CODE
      <div class="contextual">
        <%= link_to "\#{t 'Add'} \#{#{reference_class_name}.model_name.human}", '#', :class => "icon icon-add", :onclick => "showAndScrollTo('add_#{reference_model_name}','focus_#{reference_model_name}'); return false;"%>
      </div>
      <h3><%=#{reference_class_name}.model_name.human%></h3>
      <% @#{reference_value} = @#{model_name}.#{reference_value}.paginate(:page => params[:#{reference_model_name}_page], :order => (params[:#{reference_model_name}_sort].gsub('_reverse', ' DESC') unless params[:#{reference_model_name}_sort].blank?))%>
      <div class="autoscroll">
        <%= render :partial => 'admin/#{reference_value}/list', :locals => {:#{reference_value} => @#{reference_value}} %>
      </div>
      <%= will_paginate @#{reference_value}, :renderer => SomaticLinkRenderer %>
      <div id="add_#{reference_model_name}" style="display:none">
        <h3><%= "\#{t('New')} \#{#{reference_class_name}.model_name.human}" %></h3>
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
          inject_into_file File.join('app/views',options[:namespace], model_name.pluralize, 'show.html.erb'), :after => sentinel do
            "#{reference_list}"
          end

          inject_into_file File.join('app/views',options[:namespace], model_name.pluralize, 'edit.html.erb'), :after => sentinel do
            "#{reference_list}"
          end
        end
        
        def add_hidden_field_to_edit_view
          prepend_file File.join('app/views',options[:namespace], reference_model_name.pluralize, '_form.html.erb'), "<%= f.hidden_field :#{migration_attribute} %>"
        end
        
        def migrations
          if relationship == 'has_many'
            unless options[:skip_migration] 
              invoke "migration", [%(add_#{migration_attribute}_to_#{migration_table_name}), "#{migration_attribute}:integer"]
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
        
    end
  end
end
