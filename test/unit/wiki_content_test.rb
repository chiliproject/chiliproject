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

class WikiContentTest < ActiveSupport::TestCase
  fixtures :wikis, :wiki_pages, :wiki_contents, :journals, :users

  def setup
    @wiki = Wiki.find(1)
    @page = @wiki.pages.first
  end

  def test_create
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "Content text", :author => User.find(1), :comments => "My comment")
    assert page.save
    page.reload

    content = page.content
    assert_kind_of WikiContent, content
    assert_equal 1, content.version
    assert_equal 1, content.versions.length
    assert_equal "Content text", content.text
    assert_equal "My comment", content.versions.last.notes
    assert_equal User.find(1), content.author
    assert_equal content.text, content.versions.last.text
  end

  def test_create_should_send_email_notification
    Setting.notified_events = ['wiki_content_added']
    ActionMailer::Base.deliveries.clear
    page = WikiPage.new(:wiki => @wiki, :title => "A new page")
    page.content = WikiContent.new(:text => "Content text", :author => User.find(1), :comments => "My comment")
    assert page.save

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_update
    content = @page.content
    version_count = content.version
    content.text = "My new content"
    assert content.save
    content.reload
    assert_equal version_count+1, content.version
    assert_equal version_count+1, content.versions.length
  end

  def test_update_should_send_email_notification
    Setting.notified_events = ['wiki_content_updated']
    ActionMailer::Base.deliveries.clear
    content = @page.content
    content.text = "My new content"
    assert content.save

    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_fetch_history
    assert !@page.content.journals.empty?
    @page.content.journals.each do |journal|
      assert_kind_of String, journal.text
    end
  end

  def test_large_text_should_not_be_truncated_to_64k
    page = WikiPage.new(:wiki => @wiki, :title => "Big page")
    page.content = WikiContent.new(:text => "a" * 500.kilobyte, :author => User.find(1))
    assert page.save
    page.reload
    assert_equal 500.kilobyte, page.content.text.size
  end

  test "new WikiContent is version 0" do
    page = WikiPage.new(:wiki => @wiki, :title => "Page")
    page.content = WikiContent.new(:text => "Content text", :author => User.find(1), :comments => "My comment")

    assert_equal 0, page.content.version
  end
end
