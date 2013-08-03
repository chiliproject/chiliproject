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
  include ERB::Util
  fixtures :attachments,
           :auth_sources,
           :boards,
           :changes,
           :changesets,
           :comments,
           :custom_fields,
           :custom_fields_projects,
           :custom_fields_trackers,
           :custom_values,
           :documents,
           :enabled_modules,
           :enumerations,
           :groups_users,
           :issue_categories,
           :issue_relations,
           :issue_statuses,
           :issues,
           :journals,
           :member_roles,
           :members,
           :messages,
           :news,
           :projects,
           :projects_trackers,
           :queries,
           :repositories,
           :roles,
           :time_entries,
           :tokens,
           :trackers,
           :user_preferences,
           :users,
           :versions,
           :watchers,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :workflows

  def setup
    super
    set_language_if_valid('en')
    User.current = nil
  end

  # TODO: Move test code to Journal class
  context "IssuesHelper#show_detail" do
    context "with no_html" do
      should 'show a changing attribute' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [40, 100]}
          j.journaled = Issue.last
        end
        assert_equal "% Done changed from 40 to 100", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should 'show a new attribute' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [nil, 100]}
          j.journaled = Issue.last
        end
        assert_equal "% Done set to 100", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should 'show a deleted attribute' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [50, nil]}
          j.journaled = Issue.last
        end
        assert_equal "% Done deleted (50)", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    context "with html" do
      should 'show a changing attribute with HTML highlights' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [40, 100]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> changed from <i>40</i> to <i>100</i>", html
      end

      should 'show a new attribute with HTML highlights' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [nil, 100]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> set to <i>100</i>", html
      end

      should 'show a deleted attribute with HTML highlights' do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"done_ratio" => [50, nil]}
          j.journaled = Issue.last
        end
        html = @journal.render_detail(@journal.details.to_a.first, false)
        assert_equal "<strong>% Done</strong> deleted (<strike><i>50</i></strike>)", html
      end
    end

    context "with a start_date attribute" do
      should "format the current date" do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"start_date" => ['2010-01-01', '2010-01-31']}
          j.journaled = Issue.last
        end
        assert_match "01/31/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should "format the old date" do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"start_date" => ['2010-01-01', '2010-01-31']}
          j.journaled = Issue.last
        end
        assert_match "01/01/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    context "with a due_date attribute" do
      should "format the current date" do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"due_date" => ['2010-01-01', '2010-01-31']}
          j.journaled = Issue.last
        end
        assert_match "01/31/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end

      should "format the old date" do
        @journal = IssueJournal.create! do |j|
          j.changed_data = {"due_date" => ['2010-01-01', '2010-01-31']}
          j.journaled = Issue.last
        end
        assert_match "01/01/2010", @journal.render_detail(@journal.details.to_a.first, true)
      end
    end

    should "show old and new values with a project attribute" do
      journal = IssueJournal.new(:changed_data => {"project_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'eCookbook', detail
      assert_match 'OnlineStore', detail
    end

    should "show old and new values with a issue status attribute" do
      journal = IssueJournal.new(:changed_data => {"status_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'New', detail
      assert_match 'Assigned', detail
    end

    should "show old and new values with a tracker attribute" do
      journal = IssueJournal.new(:changed_data => {"tracker_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'Bug', detail
      assert_match 'Feature request', detail
    end

    should "show old and new values with a assigned to attribute" do
      journal = IssueJournal.new(:changed_data => {"assigned_to_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'redMine Admin', detail
      assert_match 'John Smith', detail
    end

    should "show old and new values with a priority attribute" do
      journal = IssueJournal.new(:changed_data => {"priority_id" => [4, 5]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'Low', detail
      assert_match 'Normal', detail
    end

    should "show old and new values with a category attribute" do
      journal = IssueJournal.new(:changed_data => {"category_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match 'Printing', detail
      assert_match 'Recipes', detail
    end

    should "show old and new values with a fixed version attribute" do
      journal = IssueJournal.new(:changed_data => {"fixed_version_id" => [1, 2]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match '0.1', detail
      assert_match '1.0', detail
    end

    should "show old and new values with a estimated hours attribute" do
      journal = IssueJournal.new(:changed_data => {"estimated_hours" => [5, 6.3]}, :journaled => Issue.last)
      detail = journal.render_detail(journal.details.to_a.first, true)
      assert_match '5.00', detail
      assert_match '6.30', detail
    end
    should "test custom fields"
    should "test attachments"
  end
end
