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
require 'pp'
class ApiTest::NewsTest < ActionController::IntegrationTest
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
    Setting.rest_api_enabled = '1'
  end

  context "GET /news" do
    context ".xml" do
      should "return news" do
        get '/news.xml'

        assert_tag :tag => 'news',
          :attributes => {:type => 'array'},
          :child => {
            :tag => 'news',
            :child => {
              :tag => 'id',
              :content => '2'
            }
          }
      end
    end

    context ".json" do
      should "return news" do
        get '/news.json'

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['news']
        assert_kind_of Hash, json['news'].first
        assert_equal 2, json['news'].first['id']
      end
    end
  end

  context "GET /projects/:project_id/news" do
    context ".xml" do
      should_allow_api_authentication(:get, "/projects/onlinestore/news.xml")

      should "return news" do
        get '/projects/ecookbook/news.xml'

        assert_tag :tag => 'news',
          :attributes => {:type => 'array'},
          :child => {
            :tag => 'news',
            :child => {
              :tag => 'id',
              :content => '2'
            }
          }
      end
    end

    context ".json" do
      should_allow_api_authentication(:get, "/projects/onlinestore/news.json")

      should "return news" do
        get '/projects/ecookbook/news.json'

        json = ActiveSupport::JSON.decode(response.body)
        assert_kind_of Hash, json
        assert_kind_of Array, json['news']
        assert_kind_of Hash, json['news'].first
        assert_equal 2, json['news'].first['id']
      end
    end
  end
end
