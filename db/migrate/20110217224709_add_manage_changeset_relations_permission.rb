class AddManageChangesetRelationsPermission < ActiveRecord::Migration
  def self.up
    Role.find(:all).each do |r|
      r.add_permission!(:manage_changeset_relations) if r.has_permission?(:manage_issue_relations)
    end
  end

  def self.down
    Role.find(:all).each do |r|
      r.remove_permission!(:manage_changeset_relations)
    end
  end
end
