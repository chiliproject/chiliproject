class ChangeUsersHashedPasswordLength < ActiveRecord::Migration
  def self.up
    # SHA256 digests are longer than 40 characters
    change_column :users, :hashed_password, :string, :limit => 128, :default => "", :null => false
  end

  def self.down
    change_column :users, :hashed_password, :string, :limit => 40, :default => "", :null => false
  end
end
