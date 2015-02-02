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
require 'sys_controller'
require 'mocha'

# Re-raise errors caught by the controller.
class SysController; def rescue_action(e) raise e end; end

class SysControllerTest < ActionController::TestCase
  fixtures :users, :projects, :members, :member_roles, :roles, :auth_sources, :repositories, :enabled_modules

  def setup
    @controller = SysController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    Setting.sys_api_enabled = '1'
    Setting.enabled_scm = %w(Subversion Git)
  end

  def test_projects_with_repository_enabled
    get :projects
    assert_response :success
    assert_equal 'application/xml', @response.content_type
    with_options :tag => 'projects' do |test|
      test.assert_tag :children => { :count  => Project.active.has_module(:repository).count }
    end
  end

  def test_create_project_repository
    assert_nil Project.find(4).repository

    post :create_project_repository, :id => 4,
                                     :vendor => 'Subversion',
                                     :repository => { :url => 'file:///create/project/repository/subproject2'}
    assert_response :created

    r = Project.find(4).repository
    assert r.is_a?(Repository::Subversion)
    assert_equal 'file:///create/project/repository/subproject2', r.url
  end

  def test_fetch_changesets
    Repository::Subversion.any_instance.expects(:fetch_changesets).returns(true)
    get :fetch_changesets
    assert_response :success
  end

  def test_fetch_changesets_one_project
    Repository::Subversion.any_instance.expects(:fetch_changesets).returns(true)
    get :fetch_changesets, :id => 'ecookbook'
    assert_response :success
  end

  def test_fetch_changesets_unknown_project
    get :fetch_changesets, :id => 'unknown'
    assert_response 404
  end

  def test_disabled_ws_should_respond_with_403_error
    with_settings :sys_api_enabled => '0' do
      get :projects
      assert_response 403
    end
  end

  def test_api_key
    with_settings :sys_api_key => 'my_secret_key' do
      get :projects, :key => 'my_secret_key'
      assert_response :success
    end
  end

  def test_wrong_key_should_respond_with_403_error
    with_settings :sys_api_key => 'my_secret_key' do
      get :projects, :key => 'wrong_key'
      assert_response 403
    end
  end

  context "auth" do
    should "require API key" do
      with_settings :sys_api_key => 'my_secret_key' do
        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "jsmith")
        post :auth, :key => 'wrong_key', :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 403
      end
    end

    should "validate user's permission" do
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "jsmith")
      post :auth, :id => 'ecookbook', :permission => 'browse_repository'
      assert_response 200
    end

    should "deny access with invalid credentials" do
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "wrong_password")
      post :auth, :id => 'ecookbook', :permission => 'browse_repository'
      assert_response 401
    end

    should "deny access with correct password but missing permission" do
      @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("rhill", "foo")
      post :auth, :id => 'onlinestore', :permission => 'browse_repository'
      assert_response 403
    end

    context "credential caching" do
      should "cache correct credentials" do
        Rails.cache.clear

        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "jsmith")
        post :auth, :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 200

        jsmith = User.find_by_login("jsmith")

        assert_equal jsmith, User.try_to_login("jsmith", "jsmith")
        assert_equal "2", Rails.cache.read(jsmith.auth_cache_key("jsmith"))
      end

      should "not cache wrong credentials" do
        Rails.cache.clear

        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "wrong_password")
        post :auth, :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 401

        jsmith = User.find_by_login("jsmith")
        assert_nil Rails.cache.read(jsmith.auth_cache_key("wrong_password"))
      end

      should "not allow the old password after it was changed" do
        Rails.cache.clear
        jsmith = User.find_by_login("jsmith")

        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "jsmith")
        post :auth, :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 200

        jsmith.reload
        jsmith.password = "new_password"
        jsmith.password_confirmation = "new_password"
        jsmith.save!
        # set updated_on to fix a race condition for the next tests
        User.update_all({:updated_on => Time.now - 10.seconds}, :id => jsmith.id)

        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "jsmith")
        post :auth, :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 401

        @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("jsmith", "new_password")
        post :auth, :id => 'ecookbook', :permission => 'browse_repository'
        assert_response 200

        # cleanup
        jsmith.password = "jsmith"
        jsmith.password_confirmation = "jsmith"
        jsmith.save!
      end
    end
  end
end
