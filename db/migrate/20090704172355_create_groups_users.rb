#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class CreateGroupsUsers < ActiveRecord::Migration
  def self.up
    create_table :groups_users, :id => false do |t|
      t.column :group_id, :integer, :null => false
      t.column :user_id, :integer, :null => false
    end
    add_index :groups_users, [:group_id, :user_id], :unique => true, :name => :groups_users_ids
  end

  def self.down
    drop_table :groups_users
  end
end
