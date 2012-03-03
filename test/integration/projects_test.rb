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

class ProjectsTest < ActionController::IntegrationTest
  fixtures :projects, :users, :members, :enabled_modules

  def test_archive_project
    subproject = Project.find(1).children.first
    log_user("admin", "admin")
    get "admin/projects"
    assert_response :success
    assert_template "admin/projects"
    post "projects/1/archive"
    assert_redirected_to "/admin/projects"
    assert !Project.find(1).active?

    get 'projects/1'
    assert_response 403
    get "projects/#{subproject.id}"
    assert_response 403

    post "projects/1/unarchive"
    assert_redirected_to "/admin/projects"
    assert Project.find(1).active?
    get "projects/1"
    assert_response :success
  end

  def test_modules_should_not_allow_get
    assert_no_difference 'EnabledModule.count' do
      get '/projects/1/modules', {:enabled_module_names => ['']}, credentials('jsmith')
      assert_response :method_not_allowed
    end
  end
end
