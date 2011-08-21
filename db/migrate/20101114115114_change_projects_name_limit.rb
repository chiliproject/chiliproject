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

class ChangeProjectsNameLimit < ActiveRecord::Migration
  def self.up
    change_column :projects, :name, :string, :limit => nil, :default => '', :null => false
  end

  def self.down
    change_column :projects, :name, :string, :limit => 30, :default => '', :null => false
  end
end
