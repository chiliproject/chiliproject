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

class InsertBuiltinRoles < ActiveRecord::Migration
  def self.up
    nonmember = Role.new(:name => 'Non member', :position => 0)
    nonmember.send(:attributes=, { :builtin => Role::BUILTIN_NON_MEMBER }, false)
    nonmember.save

    anonymous = Role.new(:name => 'Anonymous', :position => 0)
    anonymous.send(:attributes=, { :builtin => Role::BUILTIN_ANONYMOUS }, false)
    anonymous.save
  end

  def self.down
    Role.destroy_all 'builtin <> 0'
  end
end
