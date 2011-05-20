class AddMailFromToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :mail_from, :string
  end

  def self.down
    remove_column :projects, :mail_from
  end
end
