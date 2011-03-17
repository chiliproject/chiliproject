class AddScmMetadataToRepositories < ActiveRecord::Migration
  def self.up
    add_column :repositories, :scm_metadata, :text
  end

  def self.down
    remove_column :repositories, :scm_metadata
  end
end
