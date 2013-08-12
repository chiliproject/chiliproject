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

class AuthSourcesControllerTest < ActionController::TestCase
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

  def test_index
    get :index

    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:auth_sources)
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'
    assert_kind_of AuthSource, assigns(:auth_source)
    assert assigns(:auth_source).new_record?
  end

  def test_create
    assert_difference 'AuthSource.count' do
      post :create, :auth_source => {:name => 'Test'}
    end

    assert_redirected_to '/auth_sources'
    auth_source = AuthSource.first(:order => 'id DESC')
    assert_equal 'Test', auth_source.name
  end

  def test_edit
    auth_source = AuthSource.create!(:name => 'TestEdit')
    get :edit, :id => auth_source.id

    assert_response :success
    assert_template 'edit'
    assert_equal auth_source, assigns(:auth_source)
  end

  def test_update
    auth_source = AuthSource.create!(:name => 'TestEdit')
    post :update, :id => auth_source.id, :auth_source => {:name => 'TestUpdate'}

    assert_redirected_to '/auth_sources'
    assert_equal 'TestUpdate', auth_source.reload.name
  end

  def test_destroy_without_users
    auth_source = AuthSource.create!(:name => 'TestEdit')
    assert_difference 'AuthSource.count', -1 do
      post :destroy, :id => auth_source.id
    end

    assert_redirected_to '/auth_sources'
  end

  def test_destroy_with_users
    auth_source = AuthSource.create!(:name => 'TestEdit')
    User.find(2).update_attribute :auth_source, auth_source
    assert_no_difference 'AuthSource.count' do
      post :destroy, :id => auth_source.id
    end

    assert_redirected_to '/auth_sources'
    assert AuthSource.find(auth_source.id)
  end
end
