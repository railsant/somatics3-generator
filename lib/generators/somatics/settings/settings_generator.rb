require 'generators/somatics'
require 'rails/generators/rails/resource/resource_generator'
require 'rails/generators/resource_helpers'
require 'rails/generators/migration'

module Somatics
  module Generators
    class SettingsGenerator < Rails::Generators::Base
      include Rails::Generators::Migration
      
      def generate_model
        invoke "somatics:scaffold", ["settings" , "name:string", "field_type:string", "value:text", "category:string", "description:text", "mce_editable:boolean"], {:scaffold_controller => "settings_controller"}
      end
      
      def add_name_index
        inject_into_file Dir.glob("db/migrate/[0-9]*_*.rb").last, :before => "end\n\n  def self.down" do
          "add_index :settings, :name, :unique => true\n"
        end
      end
      
      def inject_model_validators
        inject_into_class 'app/models/setting.rb', 'Setting' do 
          <<-RUBY
  GENERAL = 'General'
  CATEGORIES = [GENERAL]
  FIELD_TYPES = ['integer', 'string', 'float', 'text', 'boolean']

  attr_protected :name, :field_type, :description, :category, :mce_editable

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :field_type
  validates_inclusion_of :field_type, :in => FIELD_TYPES
  validates_presence_of :category
  validates_inclusion_of :category, :in => CATEGORIES
  validates_presence_of :value, :allow_blank => true
  validates_numericality_of :value, :if => Proc.new {|setting| ['integer', 'float'].include?(setting.field_type) }

  def self.[](name)
    raise SettingNotFound unless setting = Setting.find_by_name(name)
    setting.parsed_value
  end

  def self.[]=(name, value)
    raise SettingNotFound unless setting = Setting.find_by_name(name)
    setting.update_attribute(:value, value)
  end

  def parsed_value
    case self.field_type
    when 'integer'
      self.value.to_i
    when 'float'
      self.value.to_f
    when 'boolean'
      self.value == '1'
    else
      self.value
    end
  end

  def input_field(form)
    options = {}
    input_field_type = case self.field_type
    when 'integer', 'string', 'float'
      'text_field'
    when 'text'
      options[:class] = 'mceEditor'
      'text_area'
    when 'boolean'
      'check_box'
    else
      'text_field'
    end
    form.send(input_field_type, :value, options)
  end

  class SettingNotFound < Exception; end
  
          RUBY
        end rescue nil
      
      end
    end
  end
end
