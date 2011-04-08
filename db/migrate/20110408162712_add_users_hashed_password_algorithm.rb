class AddUsersHashedPasswordAlgorithm < ActiveRecord::Migration
  def self.up
    add_column :users, :hashed_password_algorithm, :string, :limit => 64
  end

  def self.down
    remove_column :users, :hashed_password_algorithm
  end
end
