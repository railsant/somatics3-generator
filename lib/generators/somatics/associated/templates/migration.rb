class <%= "add_#{migration_attribute}_to_#{migration_table_name}".camelize %> < ActiveRecord::Migration
  def self.up
    add_column :<%= migration_table_name %>, :<%= migration_attribute %>, :integer
    add_index :<%= migration_table_name %>, :<%= migration_attribute %>
  end

  def self.down
    remove_index :<%= migration_table_name %>, :<%= migration_attribute %>
    remove_column :<%= migration_table_name %>, :<%= migration_attribute %>
  end
end