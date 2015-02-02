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

class UserPreferenceTest < ActiveSupport::TestCase
  fixtures :users, :user_preferences

  def test_create
    user = User.new(:firstname => "new", :lastname => "user", :mail => "newuser@somenet.foo")
    user.login = "newuser"
    user.password, user.password_confirmation = "password", "password"
    assert user.save

    assert_kind_of UserPreference, user.pref
    assert_kind_of Hash, user.pref.others
    assert user.pref.save
  end

  def test_update
    user = User.find(1)
    assert_equal true, user.pref.hide_mail
    user.pref['preftest'] = 'value'
    assert user.pref.save

    user.reload
    assert_equal 'value', user.pref['preftest']
  end
  
  def test_settings_default_preference_theme
    Setting.ui_theme = "alternate"
    
    user = User.new(:firstname => "new", :lastname => "user", :mail => "newuser@somenet.foo")
    user.login = "newuser"
    user.password, user.password_confirmation = "password", "password"
    assert user.save
    
    assert user.pref.ui_theme, Setting.ui_theme
  end
  
  def test_overridden_theme
    user = User.find(1)
    user.pref.ui_theme = "alternate"
    assert user.pref.save
    
    assert user.pref.ui_theme, "alternate"
  end
  
  def test_overridden_invalid_theme
    Setting.ui_theme = "alternate"
    
    user = User.find(1)
    user.pref.ui_theme = "invalid_theme"
    assert user.pref.save
    
    assert_not_equal user.pref.ui_theme, "invalid_theme"
    assert_equal user.pref.ui_theme, Setting.ui_theme
  end
  
  def test_default_preference_theme
    Setting.ui_theme = "alternate"
    
    user = User.find(1)
    user.pref.ui_theme = ""
    assert user.pref.save
    
    assert_equal user.pref.ui_theme, ""
  end
end
