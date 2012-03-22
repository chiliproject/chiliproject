#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++
require File.expand_path('../../test_helper', __FILE__)

class SettingTest < ActiveSupport::TestCase

  def test_read_default
    assert_equal "ChiliProject", Setting.app_title
    assert Setting.self_registration?
    assert !Setting.login_required?
  end

  def test_update
    Setting.app_title = "My title"
    assert_equal "My title", Setting.app_title
    # make sure db has been updated (INSERT)
    assert_equal "My title", Setting.find_by_name('app_title').value

    Setting.app_title = "My other title"
    assert_equal "My other title", Setting.app_title
    # make sure db has been updated (UPDATE)
    assert_equal "My other title", Setting.find_by_name('app_title').value
  end

  def test_serialized_setting
    Setting.notified_events = ['issue_added', 'issue_updated', 'news_added']
    assert_equal ['issue_added', 'issue_updated', 'news_added'], Setting.notified_events
    assert_equal ['issue_added', 'issue_updated', 'news_added'], Setting.find_by_name('notified_events').value
  end

  def test_find_or_default
    Setting.available_settings["plugin_foo"] = {'default' => {:name => nil, :version => nil}, 'serialized' => true}
    assert_equal Hash, Setting.find_or_default('plugin_issue_widget').value.class
  end

  def test_create_new_setting_with_hash
    setting = Setting.new
    setting.name = "plugin_foo"
    setting.value = {:bar => 2}
    assert_equal Hash, setting.value.class 

    setting = Setting.new
    setting.value = {:bar => 2}
    setting.name = "plugin_foo"
    assert_equal Hash, setting.value.class 
  end

end
