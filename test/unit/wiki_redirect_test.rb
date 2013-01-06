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

class WikiRedirectTest < ActiveSupport::TestCase
  fixtures :projects, :wikis, :wiki_pages

  def setup
    @wiki = Wiki.find(1)
    @original = WikiPage.create(:wiki => @wiki, :title => 'Original title')
  end

  def test_create_redirect
    @original.title = 'New title'
    assert @original.save
    @original.reload

    assert_equal 'New_title', @original.title
    assert @wiki.redirects.find_by_title('Original_title')
    assert @wiki.find_page('Original title')
    assert @wiki.find_page('ORIGINAL title')
  end

  def test_update_redirect
    # create a redirect that point to this page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.title = 'New title'
    @original.save
    # make sure the old page now points to the new page
    assert_equal 'New_title', @wiki.find_page('An old page').title
  end

  def test_reverse_rename
    # create a redirect that point to this page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.title = 'An old page'
    @original.save
    assert !@wiki.redirects.find_by_title_and_redirects_to('An_old_page', 'An_old_page')
    assert @wiki.redirects.find_by_title_and_redirects_to('Original_title', 'An_old_page')
  end

  def test_rename_to_already_redirected
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Other_page')

    @original.title = 'An old page'
    @original.save
    # this redirect have to be removed since 'An old page' page now exists
    assert !@wiki.redirects.find_by_title_and_redirects_to('An_old_page', 'Other_page')
  end

  def test_redirects_removed_when_deleting_page
    assert WikiRedirect.create(:wiki => @wiki, :title => 'An_old_page', :redirects_to => 'Original_title')

    @original.destroy
    assert !@wiki.redirects.find(:first)
  end
end
