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

class ReportsControllerTest < ActionController::TestCase
  fixtures :all

  def setup
  end

  def test_get_issue_report
    get :issue_report, :id => 1

    assert_response :success
    assert_template 'issue_report'

    [:issues_by_tracker, :issues_by_version, :issues_by_category, :issues_by_assigned_to,
     :issues_by_author, :issues_by_subproject].each do |ivar|
      assert_not_nil assigns(ivar)
    end
  end

  def test_get_issue_report_details
    %w(tracker version priority category assigned_to author subproject).each do |detail|
      get :issue_report_details, :id => 1, :detail => detail

      assert_response :success
      assert_template 'issue_report_details'
      assert_not_nil assigns(:field)
      assert_not_nil assigns(:rows)
      assert_not_nil assigns(:data)
      assert_not_nil assigns(:report_title)
    end
  end

  def test_get_issue_report_details_with_an_invalid_detail
    get :issue_report_details, :id => 1, :detail => 'invalid'

    assert_redirected_to '/projects/ecookbook/issues/report'
  end
end
