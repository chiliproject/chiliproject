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
  fixtures :all

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
end
