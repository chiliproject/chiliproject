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

class LdapAuthSourcesControllerTest < ActionController::TestCase
  fixtures :attachments,
           :auth_sources,
           :boards,
           :changes,
           :changesets,
           :comments,
           :custom_fields,
           :custom_fields_projects,
           :custom_fields_trackers,
           :custom_values,
           :documents,
           :enabled_modules,
           :enumerations,
           :groups_users,
           :issue_categories,
           :issue_relations,
           :issue_statuses,
           :issues,
           :journals,
           :member_roles,
           :members,
           :messages,
           :news,
           :projects,
           :projects_trackers,
           :queries,
           :repositories,
           :roles,
           :time_entries,
           :tokens,
           :trackers,
           :user_preferences,
           :users,
           :versions,
           :watchers,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :workflows

  def setup
    @request.session[:user_id] = 1
  end

  def test_get_new
    get :new

    assert_not_nil assigns(:auth_source)
    assert_response :success
    assert_template :new

    assert_equal AuthSourceLdap, assigns(:auth_source).class
    assert assigns(:auth_source).new_record?
  end

  def test_test_connection
    AuthSourceLdap.any_instance.stubs(:test_connection).returns(true)

    get :test_connection, :id => 1
    assert_redirected_to '/ldap_auth_sources'
    assert_not_nil flash[:notice]
    assert_match /successful/i, flash[:notice]
  end

  def test_test_connection_with_failure
    AuthSourceLdap.any_instance.stubs(:test_connection).raises(Exception.new("Something went wrong"))

    get :test_connection, :id => 1
    assert_redirected_to '/ldap_auth_sources'
    assert_not_nil flash[:error]
    assert_include '(Something went wrong)', flash[:error]
  end
end
