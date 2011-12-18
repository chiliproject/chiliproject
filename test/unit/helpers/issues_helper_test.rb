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

class IssuesHelperTest < ActionView::TestCase
  include ApplicationHelper
  include IssuesHelper

  fixtures :all

  def setup
    super
    set_language_if_valid('en')
    User.current = nil
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
        @journal = IssueJournal.create! do |j|
          j.changes = {"done_ratio" => [40, 100]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> changed from <i>40</i> to <i>100</i>", html
      end

      should 'show a new attribute with HTML highlights' do
        @journal = IssueJournal.create! do |j|
          j.changes = {"done_ratio" => [nil, 100]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> set to <i>100</i>", html
      end

      should 'show a deleted attribute with HTML highlights' do
        @journal = IssueJournal.create! do |j|
          j.changes = {"done_ratio" => [50, nil]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> deleted (<strike><i>50</i></strike>)", html
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

    context "with a project attribute" do
      should_show_the_old_and_new_values_for('project_id', Project)
    end

    context "with a issue status attribute" do
      should_show_the_old_and_new_values_for('status_id', IssueStatus)
    end

    context "with a tracker attribute" do
      should_show_the_old_and_new_values_for('tracker_id', Tracker)
    end

    context "with a assigned to attribute" do
      should_show_the_old_and_new_values_for('assigned_to_id', User)
    end

    context "with a priority attribute" do
      should_show_the_old_and_new_values_for('priority_id', IssuePriority) do
        @old_value = IssuePriority.generate!(:type => 'IssuePriority')
        @new_value = IssuePriority.generate!(:type => 'IssuePriority')
      end
    end

    context "with a category attribute" do
      should_show_the_old_and_new_values_for('category_id', IssueCategory)
    end

    context "with a fixed version attribute" do
      should_show_the_old_and_new_values_for('fixed_version_id', Version)
    end

    context "with a estimated hours attribute" do
      should "format the time into two decimal places"
      should "format the old time into two decimal places"
    end

    should "test custom fields"
    should "test attachments"

  end

end
