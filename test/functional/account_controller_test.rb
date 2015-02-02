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
require 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < ActionController::TestCase
  fixtures :users, :roles, :auth_sources

  def setup
    super
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  context "simple login" do
    should "redirect to back url param" do
      # request.uri is "test.host" in test environment
      post :login, :username => 'jsmith', :password => 'jsmith', :back_url => 'http%3A%2F%2Ftest.host%2Fissues%2Fshow%2F1'
      assert_redirected_to '/issues/show/1'
    end

    should "not redirect to another host" do
      post :login, :username => 'jsmith', :password => 'jsmith', :back_url => 'http%3A%2F%2Ftest.foo%2Ffake'
      assert_redirected_to '/my/page'
    end

    should "not login with wrong password" do
      post :login, :username => 'admin', :password => 'bad'
      assert_response :success
      assert_template 'login'
      assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
    end

    should "display login template" do
      get :login
      assert_template 'login'
    end

    should "redirect to home_url if user is already login" do
      @request.session[:user_id] = 2
      get :login
      assert_redirected_to home_url
    end

    should "not login with wrong login and password" do
      post :login, :username => 'admin_bad', :password => 'bad'
      assert_response :success
      assert_template 'login'
      assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
    end

    context "using LDAP authorization" do
      setup do
        @user = User.find(1)
        @user_with_ldap = User.find(12)
      end
      if ldap_configured?
        p "LDAP is ONLINE"
        should "get error message if user account do not exist in LDAP database" do
          post :login, :username => @user.login, :password => "123456"
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
        end

        should "login user if password and login is correct and user exist in LDAP" do
          post :login, :username => @user_with_ldap.login, :password => "123456"
          assert_redirected_to '/my/page'
        end

        should "display error because password is from local db but user use LDAP authorization" do
          post :login, :username => @user_with_ldap.login, :password => "foo"
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
        end

        should "login user using login and password from local db instead of LDAP after change authorization source" do
          auth_source = @user_with_ldap.auth_source_id
          @user_with_ldap.auth_source_id = nil
          @user_with_ldap.save
          post :login, :username => @user_with_ldap.login, :password => "123456"
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
          @user_with_ldap.auth_source_id = auth_source
          @user_with_ldap.save
        end

        should "display error when user change authorization source and still want use login and pass from LDAP" do
          auth_source = @user_with_ldap.auth_source_id
          @user_with_ldap.auth_source_id = nil
          @user_with_ldap.save
          post :login, :username => @user_with_ldap.login, :password => "123456"
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
          @user_with_ldap.auth_source_id = auth_source
          @user_with_ldap.save
        end

        should "display error message if password is incorect" do
          post :login, :username => @user.login, :password => "a123456"
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
        end

        should "login display error message if login and password are incorrect" do
          post :login, :username => "asd@user.login", :password => "1234563"
          assert_response :success
          assert_template 'login'
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
        end

        should "login display error message if password is incorrect" do
          post :login, :username => "john", :password => "s123456"
          assert_response :success
          assert_template 'login'
          assert_tag 'div',
                 :attributes => { :class => "flash error" },
                 :content => I18n.t(:notice_account_invalid_creditentials)
        end

      else
        p "LDAP is OFFLINE"
        should "display error message that LDAP authorization is offline" do
          post :login, :username => @user_with_ldap.login, :password => "123456"
          assert_response :success
          assert_template 'login'
          assert_tag 'div',
                   :attributes => { :class => "flash error" },
                   :content => I18n.t(:error_auth_source_offline)
        end
      end
    end
  end

  if Object.const_defined?(:OpenID)

    def test_login_with_openid_for_existing_user
      Setting.self_registration = '3'
      Setting.openid = '1'
      existing_user = User.new(:firstname => 'Cool',
                               :lastname => 'User',
                               :mail => 'user@somedomain.com',
                               :identity_url => 'http://openid.example.com/good_user')
      existing_user.login = 'cool_user'
      assert existing_user.save!

      post :login, :openid_url => existing_user.identity_url
      assert_redirected_to '/my/page'
    end

    def test_login_with_invalid_openid_provider
      Setting.self_registration = '0'
      Setting.openid = '1'
      post :login, :openid_url => 'http;//openid.example.com/good_user'
      assert_redirected_to home_url
    end

    def test_login_with_openid_for_existing_non_active_user
      Setting.self_registration = '2'
      Setting.openid = '1'
      existing_user = User.new(:firstname => 'Cool',
                               :lastname => 'User',
                               :mail => 'user@somedomain.com',
                               :identity_url => 'http://openid.example.com/good_user',
                               :status => User::STATUS_REGISTERED)
      existing_user.login = 'cool_user'
      assert existing_user.save!

      post :login, :openid_url => existing_user.identity_url
      assert_redirected_to '/login'
    end

    def test_login_with_openid_with_new_user_created
      Setting.self_registration = '3'
      Setting.openid = '1'
      post :login, :openid_url => 'http://openid.example.com/good_user'
      assert_redirected_to '/my/account'
      user = User.find_by_login('cool_user')
      assert user
      assert_equal 'Cool', user.firstname
      assert_equal 'User', user.lastname
    end

    def test_login_with_openid_with_new_user_and_self_registration_off
      Setting.self_registration = '0'
      Setting.openid = '1'
      post :login, :openid_url => 'http://openid.example.com/good_user'
      assert_redirected_to home_url
      user = User.find_by_login('cool_user')
      assert ! user
    end

    def test_login_with_openid_with_new_user_created_with_email_activation_should_have_a_token
      Setting.self_registration = '1'
      Setting.openid = '1'
      post :login, :openid_url => 'http://openid.example.com/good_user'
      assert_redirected_to '/login'
      user = User.find_by_login('cool_user')
      assert user

      token = Token.find_by_user_id_and_action(user.id, 'register')
      assert token
    end

    def test_login_with_openid_with_new_user_created_with_manual_activation
      Setting.self_registration = '2'
      Setting.openid = '1'
      post :login, :openid_url => 'http://openid.example.com/good_user'
      assert_redirected_to '/login'
      user = User.find_by_login('cool_user')
      assert user
      assert_equal User::STATUS_REGISTERED, user.status
    end

    def test_login_with_openid_with_new_user_with_conflict_should_register
      Setting.self_registration = '3'
      Setting.openid = '1'
      existing_user = User.new(:firstname => 'Cool', :lastname => 'User', :mail => 'user@somedomain.com')
      existing_user.login = 'cool_user'
      assert existing_user.save!

      post :login, :openid_url => 'http://openid.example.com/good_user'
      assert_response :success
      assert_template 'register'
      assert assigns(:user)
      assert_equal 'http://openid.example.com/good_user', assigns(:user)[:identity_url]
    end

    def test_setting_openid_should_return_true_when_set_to_true
      Setting.openid = '1'
      assert_equal true, Setting.openid?
    end

  else
    puts "Skipping openid tests."
  end

  def test_logout
    @request.session[:user_id] = 2
    get :logout
    assert_redirected_to '/'
    assert_nil @request.session[:user_id]
  end

  context "GET #register" do
    context "with self registration on" do
      setup do
        Setting.self_registration = '3'
        get :register
      end

      should_respond_with :success
      should_render_template :register
      should_assign_to :user
    end

    context "with self registration off" do
      setup do
        Setting.self_registration = '0'
        get :register
      end

      should_redirect_to('/') { home_url }
    end
  end

  # See integration/account_test.rb for the full test
  context "POST #register" do
    context "with self registration on automatic" do
      setup do
        Setting.self_registration = '3'
        post :register, :user => {
          :login => 'register',
          :password => 'test',
          :password_confirmation => 'test',
          :firstname => 'John',
          :lastname => 'Doe',
          :mail => 'register@example.com'
        }
      end

      should_respond_with :redirect
      should_assign_to :user
      should_redirect_to('my page') { {:controller => 'my', :action => 'account'} }

      should_create_a_new_user { User.last(:conditions => {:login => 'register'}) }

      should 'set the user status to active' do
        user = User.last(:conditions => {:login => 'register'})
        assert user
        assert_equal User::STATUS_ACTIVE, user.status
      end
    end

    context "with self registration off" do
      setup do
        Setting.self_registration = '0'
        post :register
      end

      should_redirect_to('/') { home_url }
    end
  end

end
