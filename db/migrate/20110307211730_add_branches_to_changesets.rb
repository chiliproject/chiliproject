class AddBranchesToChangesets < ActiveRecord::Migration
  def self.up
    add_column :changesets, :branches, :string
  end

  def self.down
    remove_column :changesets, :branches
  end
end
