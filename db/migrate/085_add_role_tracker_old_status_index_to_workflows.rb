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

class AddRoleTrackerOldStatusIndexToWorkflows < ActiveRecord::Migration
  def self.up
    add_index :workflows, [:role_id, :tracker_id, :old_status_id], :name => :wkfs_role_tracker_old_status
  end

  def self.down
    remove_index(:workflows, :name => :wkfs_role_tracker_old_status); rescue
  end
end
