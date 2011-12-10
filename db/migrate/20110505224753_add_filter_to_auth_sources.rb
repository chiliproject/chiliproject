class AddFilterToAuthSources < ActiveRecord::Migration
  def self.up
    add_column :auth_sources, :filter, :string, :limit => 255
  end

  def self.down
    remove_column :auth_sources, :filter
  end
end

