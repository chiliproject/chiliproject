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
require 'capybara/rails'

class JournalsTest < ActionController::IntegrationTest
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

  include IntegrationTestHelpers::CapybaraHelpers
  include Capybara::DSL

  test "showing issue description changes as a diff" do
    # Description change
    @issue = Issue.find(1)
    @issue.recreate_initial_journal!
    @issue.reload
    assert_difference("Journal.count") do
      @issue.journal_user = User.find_by_login('jsmith')
      @issue.description = "A new description"
      assert @issue.save
    end

    log_user('jsmith', 'jsmith')

    # Issue page
    visit_issue_page(@issue)
    assert has_selector?("#history .journal-attributes li i", :text => 'A new description')
    within("#history .journal-attributes li") do
      find_link("More").click
    end

    # Diff page
    assert_response :success
    assert has_selector?("#content .text-diff", :text => /A new description/)
  end
end
