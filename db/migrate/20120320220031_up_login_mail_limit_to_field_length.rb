class UpLoginMailLimitToFieldLength < ActiveRecord::Migration
  def self.up
    change_column :users, :login, :string, :limit => nil
    change_column :users, :mail, :string, :limit => nil
  end

  def self.down
    change_column :users, :login, :string, :limit => 30
    change_column :users, :mail, :string, :limit => 60
  end
end
