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

class IssuesHelperTest < HelperTestCase
  include ApplicationHelper
  include IssuesHelper
  include CustomFieldsHelper
  include ERB::Util

  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules,
           :workflows,
           :custom_fields,
           :attachments

  def setup
    super
    set_language_if_valid('en')
    User.current = nil
    @response = ActionController::TestResponse.new
  end

  def controller
    @controller ||= IssuesController.new
  end

  def request
    @request ||= ActionController::TestRequest.new
  end

  # TODO: Move test code to Journal class
  context "IssuesHelper#show_detail" do
    context "with no_html" do
      should 'show a changing attribute' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [40, 100]}, :journaled => Issue.last)
        assert_equal "% Done changed from 40 to 100", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should 'show a new attribute' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [nil, 100]}, :journaled => Issue.last)
        assert_equal "% Done set to 100", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should 'show a deleted attribute' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [50, nil]}, :journaled => Issue.last)
        assert_equal "% Done deleted (50)", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    context "with html" do
      should 'show a changing attribute with HTML highlights' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [40, 100]}, :journaled => Issue.last)
        @response.body = @journal.render_detail(@journal.details.to_a.first, false)

        assert_select 'strong', :text => '% Done'
        assert_select 'i', :text => '40'
        assert_select 'i', :text => '100'
      end

      should 'show a new attribute with HTML highlights' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [nil, 100]}, :journaled => Issue.last)
        @response.body = @journal.render_detail(@journal.details.to_a.first, false)

        assert_select 'strong', :text => '% Done'
        assert_select 'i', :text => '100'
      end

      should 'show a deleted attribute with HTML highlights' do
        @journal = IssueJournal.generate!(:changes => {"done_ratio" => [50, nil]}, :journaled => Issue.last)
        @response.body = @journal.render_detail(@journal.details.to_a.first, false)

        assert_select 'strong', :text => '% Done'
        assert_select 'strike' do
          assert_select 'i', :text => '50'
        end
      end
    end

    context "with a start_date attribute" do
      should "format the current date" do
        @journal = IssueJournal.generate!(:changes => {"start_date" => ['2010-01-01', '2010-01-31']}, :journaled => Issue.last)
        assert_match "01/31/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should "format the old date" do
        @journal = IssueJournal.generate!(:changes => {"start_date" => ['2010-01-01', '2010-01-31']}, :journaled => Issue.last)
        assert_match "01/01/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    context "with a due_date attribute" do
      should "format the current date" do
        @journal = IssueJournal.generate!(:changes => {"due_date" => ['2010-01-01', '2010-01-31']}, :journaled => Issue.last)
        assert_match "01/31/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should "format the old date" do
        @journal = IssueJournal.generate!(:changes => {"due_date" => ['2010-01-01', '2010-01-31']}, :journaled => Issue.last)
        assert_match "01/01/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    should "show old and new values with a project attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'project_id', :old_value => 1, :value => 2)
      assert_match 'eCookbook', show_detail(detail, true)
      assert_match 'OnlineStore', show_detail(detail, true)
    end

    should "show old and new values with a issue status attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'status_id', :old_value => 1, :value => 2)
      assert_match 'New', show_detail(detail, true)
      assert_match 'Assigned', show_detail(detail, true)
    end

    should "show old and new values with a tracker attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'tracker_id', :old_value => 1, :value => 2)
      assert_match 'Bug', show_detail(detail, true)
      assert_match 'Feature request', show_detail(detail, true)
    end

    should "show old and new values with a assigned to attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'assigned_to_id', :old_value => 1, :value => 2)
      assert_match 'redMine Admin', show_detail(detail, true)
      assert_match 'John Smith', show_detail(detail, true)
    end

    should "show old and new values with a priority attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'priority_id', :old_value => 4, :value => 5)
      assert_match 'Low', show_detail(detail, true)
      assert_match 'Normal', show_detail(detail, true)
    end

    should "show old and new values with a category attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'category_id', :old_value => 1, :value => 2)
      assert_match 'Printing', show_detail(detail, true)
      assert_match 'Recipes', show_detail(detail, true)
    end

    should "show old and new values with a fixed version attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'fixed_version_id', :old_value => 1, :value => 2)
      assert_match '0.1', show_detail(detail, true)
      assert_match '1.0', show_detail(detail, true)
    end

    should "show old and new values with a estimated hours attribute" do
      detail = JournalDetail.generate!(:property => 'attr', :prop_key => 'estimated_hours', :old_value => '5', :value => '6.3')
      assert_match '5.00', show_detail(detail, true)
      assert_match '6.30', show_detail(detail, true)
    end

    should "show old and new values with a custom field" do
      detail = JournalDetail.generate!(:property => 'cf', :prop_key => '1', :old_value => 'MySQL', :value => 'PostgreSQL')
      assert_equal 'Database changed from MySQL to PostgreSQL', show_detail(detail, true)
    end

    should "show added file" do
      detail = JournalDetail.generate!(:property => 'attachment', :prop_key => '1', :old_value => nil, :value => 'error281.txt')
      assert_match 'error281.txt', show_detail(detail, true)
    end

    should "show removed file" do
      detail = JournalDetail.generate!(:property => 'attachment', :prop_key => '1', :old_value => 'error281.txt', :value => nil)
      assert_match 'error281.txt', show_detail(detail, true)
    end
  end
end
