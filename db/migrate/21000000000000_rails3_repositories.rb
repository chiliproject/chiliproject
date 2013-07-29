class Rails3Repositories < ActiveRecord::Migration
  def self.up
    rename_column :repositories, :type, :type_rails2
    add_column :repositories, :type, :string
    Repository.find(:all).each do |repo|
      type_rails2 = repo.type_rails2
      repo.update_attribute(:type, "Repository::" + type_rails2)
    end
  end

  def self.down
    Repository.find(:all).each do |repo|
      repo.update_attribute(:type, repo.type_rails2)
    end
    remove_column :repositories, :type_rails2
  end
end
