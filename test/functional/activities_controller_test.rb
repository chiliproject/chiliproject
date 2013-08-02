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

class ActivitiesControllerTest < ActionController::TestCase
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

  def test_project_index
    get :index, :id => 1, :with_subprojects => 0
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:events_by_day)

    assert_tag :tag => "h3",
               :content => /#{1.day.ago.to_date.day}/,
               :sibling => { :tag => "dl",
                 :child => { :tag => "dt",
                   :attributes => { :class => /issue/ },
                   :child => { :tag => "a",
                     :content => /(#{ERB::Util.h IssueStatus.find(2).name})/,
                   }
                 }
               }
  end

  def test_previous_project_index
    get :index, :id => 1, :from => 3.days.ago.to_date
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:events_by_day)

    assert_tag :tag => "h3",
               :content => /#{3.day.ago.to_date.day}/,
               :sibling => { :tag => "dl",
                 :child => { :tag => "dt",
                   :attributes => { :class => /issue/ },
                   :child => { :tag => "a",
                     :content => /#{ERB::Util.h Issue.find(1).subject}/,
                   }
                 }
               }
  end

  def test_global_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:events_by_day)

    assert_tag :tag => "h3",
               :content => /#{3.day.ago.to_date.day}/,
               :sibling => { :tag => "dl",
                 :child => { :tag => "dt",
                   :attributes => { :class => /issue/ },
                   :child => { :tag => "a",
                     :content => /#{ERB::Util.h Issue.find(1).subject}/,
                   }
                 }
               }
  end

  def test_user_index
    get :index, :user_id => 2
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:events_by_day)

    assert_tag :tag => "h3",
               :content => /#{3.day.ago.to_date.day}/,
               :sibling => { :tag => "dl",
                 :child => { :tag => "dt",
                   :attributes => { :class => /issue/ },
                   :child => { :tag => "a",
                     :content => /#{ERB::Util.h Issue.find(1).subject}/,
                   }
                 }
               }
  end

  def test_index_atom_feed
    get :index, :format => 'atom'
    assert_response :success
    assert_template 'common/feed.atom.rxml'
    assert_tag :tag => 'entry', :child => {
      :tag => 'link',
      :attributes => {:href => 'http://test.host/issues/11'}}
  end

  def test_index_without_filters
    get :index, :set_filter => 1
    assert_response :success
    assert_template 'index'
    assert_tag :tag => 'p',
      :attributes => {:class => /nodata/},
      :content => "No data to display"
  end
end
