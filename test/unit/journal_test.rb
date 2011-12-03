#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++
require File.expand_path('../../test_helper', __FILE__)

class JournalTest < ActiveSupport::TestCase
  fixtures :issues, :issue_statuses, :journals, :enumerations

  def setup
    @journal = IssueJournal.find(1)
  end

  def test_journalized_is_an_issue
    issue = @journal.journalized
    assert_kind_of Issue, issue
    assert_equal 1, issue.id
  end

  def test_new_status
    status = @journal.new_status
    assert_not_nil status
    assert_kind_of IssueStatus, status
    assert_equal 2, status.id
  end

  def test_create_should_send_email_notification
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(:first)
    if issue.journals.empty?
      issue.init_journal(User.current, "This journal represents the creationa of journal version 1")
      issue.save
    end
    user = User.find(:first)

    assert_equal 0, ActionMailer::Base.deliveries.size
    issue.reload
    issue.update_attribute(:subject, "New subject to trigger automatic journal entry")
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_create_should_not_send_email_notification_if_told_not_to
    ActionMailer::Base.deliveries.clear
    issue = Issue.find(:first)
    user = User.find(:first)
    journal = issue.init_journal(user, "A note")
    JournalObserver.instance.send_notification = false

    assert_difference("Journal.count") do
      assert issue.save
    end
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "creating the initial journal should track the changes from creation" do
    @project = Project.generate!
    issue = Issue.new do |i|
      i.project = @project
      i.subject = "Test initial journal"
      i.tracker = @project.trackers.first
      i.author = User.generate!
      i.description = "Some content"
    end

    assert_difference("Journal.count") do
      assert issue.save
    end

    journal = issue.reload.journals.first
    assert_equal ["","Test initial journal"], journal.changes["subject"]
    assert_equal [0, @project.id], journal.changes["project_id"]
    assert_equal [nil, "Some content"], journal.changes["description"]
  end

  test "creating a journal should update the updated_on value of the parent record (touch)" do
    @user = User.generate!
    @project = Project.generate!
    @issue = Issue.generate_for_project!(@project).reload
    start = @issue.updated_on
    sleep(1) # TODO: massive hack to make sure the timestamps are different. switch to timecop later

    assert_difference("Journal.count") do
      @issue.init_journal(@user, "A note")
      @issue.save
    end

    assert_not_equal start, @issue.reload.updated_on
  end

  test "accessing #journaled on a Journal should not error (parent class)" do
    journal = Journal.new
    assert_nothing_raised do
      assert_equal nil, journal.journaled
    end
  end

  test "setting journal fields through the journaled object for creation" do
    @issue = Issue.generate_for_project!(Project.generate!)

    @issue.journal_user = @issue.author
    @issue.journal_notes = 'Test setting fields on Journal from Issue'
    assert_difference('Journal.count') do
      assert @issue.save
    end

    assert_equal "Test setting fields on Journal from Issue", @issue.last_journal.notes
    assert_equal @issue.author, @issue.last_journal.user
  end

  test "subclasses of journaled models should have journal of parent type" do
    Ticket = Class.new(Issue)

    project = Project.generate!
    ticket = Ticket.new do |t|
      t.project = project
      t.subject = "Test initial journal"
      t.tracker = project.trackers.first
      t.author = User.generate!
      t.description = "Some content"
    end

    begin
      oldstdout = $stdout
      $stdout = StringIO.new
      ticket.save!
      assert $stdout.string.empty?, "No errors should be logged to stdout."
    ensure
      $stdout = oldstdout
    end

    journal = ticket.journals.first
    assert_equal IssueJournal, journal.class
  end
end
