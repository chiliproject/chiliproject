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
require 'repositories_controller'

# Re-raise errors caught by the controller.
class RepositoriesController; def rescue_action(e) raise e end; end

class RepositoriesControllerTest < ActionController::TestCase
  fixtures :projects, :users, :roles, :members, :member_roles, :enabled_modules,
           :repositories, :issues, :issue_statuses, :changesets, :changes,
           :issue_categories, :enumerations, :custom_fields, :custom_values, :trackers

  def setup
    @controller = RepositoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_new
    @request.session[:user_id] = 1
    get :new, :project_id => 'subproject1'
    assert_response :success
    assert_template 'new'
    assert_kind_of Repository::Subversion, assigns(:repository)
    assert assigns(:repository).new_record?
    assert_tag 'input', :attributes => {:name => 'repository[url]'}
  end

  # TODO: remove it when multiple SCM support is added
  def test_new_with_existing_repository
    @request.session[:user_id] = 1
    get :new, :project_id => 'ecookbook'
    assert_response 302
  end

  def test_create
    @request.session[:user_id] = 1
    assert_difference 'Repository.count' do
      post :create, :project_id => 'subproject1',
           :repository_scm => 'Subversion',
           :repository => {:url => 'file:///test'}
    end
    assert_response 302
    repository = Repository.first(:order => 'id DESC')
    assert_kind_of Repository::Subversion, repository
    assert_equal 'file:///test', repository.url
  end

  def test_create_with_failure
    @request.session[:user_id] = 1
    assert_no_difference 'Repository.count' do
      post :create, :project_id => 'subproject1',
           :repository_scm => 'Subversion',
           :repository => {:url => 'invalid'}
    end
    assert_response :success
    assert_template 'new'
    assert_kind_of Repository::Subversion, assigns(:repository)
    assert assigns(:repository).new_record?
  end

  def test_edit
    @request.session[:user_id] = 1
    get :edit, :id => 11
    assert_response :success
    assert_template 'edit'
    assert_equal Repository.find(11), assigns(:repository)
    assert_tag 'input', :attributes => {:name => 'repository[url]', :value => 'svn://localhost/test'}
  end

  def test_update
    @request.session[:user_id] = 1
    put :update, :id => 11, :repository => {:password => 'test_update'}
    assert_response 302
    assert_equal 'test_update', Repository.find(11).password
  end

  def test_update_with_failure
    @request.session[:user_id] = 1
    put :update, :id => 11, :repository => {:password => 'x'*260}
    assert_response :success
    assert_template 'edit'
    assert_equal Repository.find(11), assigns(:repository)
  end

  def test_destroy
    @request.session[:user_id] = 1
    assert_difference 'Repository.count', -1 do
      delete :destroy, :id => 11
    end
    assert_response 302
    assert_nil Repository.find_by_id(11)
  end

  def test_revisions
    get :revisions, :id => 1
    assert_response :success
    assert_template 'revisions'
    assert_not_nil assigns(:changesets)
  end

  def test_revision
    get :revision, :id => 1, :rev => 1
    assert_response :success
    assert_not_nil assigns(:changeset)
    assert_equal "1", assigns(:changeset).revision
  end

  def test_revision_with_before_nil_and_afer_normal
    get :revision, {:id => 1, :rev => 1}
    assert_response :success
    assert_template 'revision'
    assert_no_tag :tag => "div", :attributes => { :class => "contextual" },
      :child => { :tag => "a", :attributes => { :href => '/projects/ecookbook/repository/revisions/0'}
    }
    assert_tag :tag => "div", :attributes => { :class => "contextual" },
        :child => { :tag => "a", :attributes => { :href => '/projects/ecookbook/repository/revisions/2'}
    }
  end

  def test_graph_commits_per_month
    get :graph, :id => 1, :graph => 'commits_per_month'
    assert_response :success
    assert_equal 'image/svg+xml', @response.content_type
  end

  def test_graph_commits_per_author
    get :graph, :id => 1, :graph => 'commits_per_author'
    assert_response :success
    assert_equal 'image/svg+xml', @response.content_type
  end

  def test_get_committers
    @request.session[:user_id] = 2
    # add a commit with an unknown user
    Changeset.create!(
        :repository => Project.find(1).repository,
        :committer  => 'foo',
        :committed_on => Time.now,
        :revision => 100,
        :comments => 'Committed by foo.'
     )

    get :committers, :id => 10
    assert_response :success
    assert_template 'committers'

    assert_tag :td, :content => 'dlopper',
                    :sibling => { :tag => 'td',
                                  :child => { :tag => 'select', :attributes => { :name => %r{^committers\[\d+\]\[\]$} },
                                                                :child => { :tag => 'option', :content => 'Dave Lopper',
                                                                                              :attributes => { :value => '3', :selected => 'selected' }}}}
    assert_tag :td, :content => 'foo',
                    :sibling => { :tag => 'td',
                                  :child => { :tag => 'select', :attributes => { :name => %r{^committers\[\d+\]\[\]$} }}}
    assert_no_tag :td, :content => 'foo',
                       :sibling => { :tag => 'td',
                                     :descendant => { :tag => 'option', :attributes => { :selected => 'selected' }}}
  end

  def test_post_committers
    @request.session[:user_id] = 2
    # add a commit with an unknown user
    c = Changeset.create!(
            :repository => Project.find(1).repository,
            :committer  => 'foo',
            :committed_on => Time.now,
            :revision => 100,
            :comments => 'Committed by foo.'
          )
    assert_no_difference "Changeset.count(:conditions => 'user_id = 3')" do
      post :committers, :id => 10, :committers => { '0' => ['foo', '2'], '1' => ['dlopper', '3']}
      assert_response 302
      assert_equal User.find(2), c.reload.user
    end
  end
end
