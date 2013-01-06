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
require File.expand_path('../../test_helper', __FILE__)

class GroupTest < ActiveSupport::TestCase
  fixtures :all

  include Redmine::I18n

  def test_create
    g = Group.new(:lastname => 'New group')
    assert g.save
  end

  def test_blank_name_error_message
    set_language_if_valid 'en'
    new_group = Group.new
    assert !new_group.valid?
    assert new_group.errors.full_messages.include? "Name can't be blank"
  end

  def test_roles_given_to_new_user
    group = Group.find(11)
    user = User.find(9)
    project = Project.first

    Member.create!(:principal => group, :project => project, :role_ids => [1, 2])
    group.users << user
    assert user.member_of?(project)
  end

  def test_roles_given_to_existing_user
    group = Group.find(11)
    user = User.find(9)
    project = Project.first

    group.users << user
    m = Member.create!(:principal => group, :project => project, :role_ids => [1, 2])
    assert user.member_of?(project)
  end

  def test_roles_updated
    group = Group.find(11)
    user = User.find(9)
    project = Project.first
    group.users << user
    m = Member.create!(:principal => group, :project => project, :role_ids => [1])
    assert_equal [1], user.reload.roles_for_project(project).collect(&:id).sort

    m.role_ids = [1, 2]
    assert_equal [1, 2], user.reload.roles_for_project(project).collect(&:id).sort

    m.role_ids = [2]
    assert_equal [2], user.reload.roles_for_project(project).collect(&:id).sort

    m.role_ids = [1]
    assert_equal [1], user.reload.roles_for_project(project).collect(&:id).sort
  end

  def test_roles_removed_when_removing_group_membership
    assert User.find(8).member_of?(Project.find(5))
    Member.find_by_project_id_and_user_id(5, 10).destroy
    assert !User.find(8).member_of?(Project.find(5))
  end

  def test_roles_removed_when_removing_user_from_group
    assert User.find(8).member_of?(Project.find(5))
    User.find(8).groups.clear
    assert !User.find(8).member_of?(Project.find(5))
  end
end
