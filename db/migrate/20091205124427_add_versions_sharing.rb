#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class AddVersionsSharing < ActiveRecord::Migration
  def self.up
    add_column :versions, :sharing, :string, :default => 'none', :null => false
    add_index :versions, :sharing
  end

  def self.down
    remove_column :versions, :sharing
  end
end
