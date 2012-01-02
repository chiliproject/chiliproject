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

require File.expand_path('../../../test_helper', __FILE__)

class ApiTest::DisabledRestApiTest < ActionController::IntegrationTest
  fixtures :all

  def setup
    Setting.rest_api_enabled = '0'
    Setting.login_required = '1'
  end

  def teardown
    Setting.rest_api_enabled = '1'
    Setting.login_required = '0'
  end

  def test_with_a_valid_api_token
    @user = User.generate_with_protected!
    @token = Token.create!(:user => @user, :action => 'api')

    get "/news.xml?key=#{@token.value}"
    assert_response :unauthorized
    assert_equal User.anonymous, User.current

    get "/news.json?key=#{@token.value}"
    assert_response :unauthorized
    assert_equal User.anonymous, User.current
  end

  def test_with_valid_username_password_http_authentication
    @user = User.generate_with_protected!(:password => 'my_password', :password_confirmation => 'my_password')

    get "/news.xml", nil, credentials(@user.login, 'my_password')
    assert_response :unauthorized
    assert_equal User.anonymous, User.current

    get "/news.json", nil, credentials(@user.login, 'my_password')
    assert_response :unauthorized
    assert_equal User.anonymous, User.current
  end

  def test_with_valid_token_http_authentication
    @user = User.generate_with_protected!
    @token = Token.create!(:user => @user, :action => 'api')

    get "/news.xml", nil, credentials(@token.value, 'X')
    assert_response :unauthorized
    assert_equal User.anonymous, User.current

    get "/news.json", nil, credentials(@token.value, 'X')
    assert_response :unauthorized
    assert_equal User.anonymous, User.current
  end
end
