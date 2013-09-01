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

class RoutingTest < ActionController::IntegrationTest
  context "activities" do
    should_route :get, "/activity", :controller => 'activities', :action => 'index', :id => nil
    should_route :get, "/activity.atom", :controller => 'activities', :action => 'index', :id => nil, :format => 'atom'
  end

  context "groups" do
    should_route :post,   "/groups/567/users", :controller => 'groups', :action => 'add_users', :id => '567'
    should_route :delete, "/groups/567/users/12", :controller => 'groups', :action => 'remove_user', :id => '567', :user_id => '12'
  end

  context "issues" do
    # Extra actions
    should_route :get, "/issues/move/new", :controller => 'issue_moves', :action => 'new'
    should_route :post, "/issues/move", :controller => 'issue_moves', :action => 'create'

    should_route :post, "/issues/1/quoted", :controller => 'journals', :action => 'new', :id => '1'

    should_route :get, "/issues/calendar", :controller => 'calendars', :action => 'show'
    should_route :get, "/projects/project-name/issues/calendar", :controller => 'calendars', :action => 'show', :project_id => 'project-name'

    should_route :get, "/issues/gantt", :controller => 'gantts', :action => 'show'
    should_route :get, "/projects/project-name/issues/gantt", :controller => 'gantts', :action => 'show', :project_id => 'project-name'

    should_route :get, "/issues/auto_complete", :controller => 'auto_completes', :action => 'issues'

    should_route :get, "/issues/preview/123", :controller => 'previews', :action => 'issue', :id => '123'
    should_route :post, "/issues/preview/123", :controller => 'previews', :action => 'issue', :id => '123'
    should_route :get, "/issues/context_menu", :controller => 'context_menus', :action => 'issues'
    should_route :post, "/issues/context_menu", :controller => 'context_menus', :action => 'issues'

    should_route :get, "/issues/changes", :controller => 'journals', :action => 'index'
  end

  context "journals" do
    should_route :get, "/journals/100/diff/description", :controller => 'journals', :action => 'diff', :id => '100', :field => 'description'
  end

  context "issue relations" do
    should_route :post, "/issues/1/relations", :controller => 'issue_relations', :action => 'create', :issue_id => '1'
    should_route :post, "/issues/1/relations.xml", :controller => 'issue_relations', :action => 'create', :issue_id => '1', :format => 'xml'
    should_route :post, "/issues/1/relations.json", :controller => 'issue_relations', :action => 'create', :issue_id => '1', :format => 'json'

    should_route :get, "/issues/1/relations/23", :controller => 'issue_relations', :action => 'show', :issue_id => '1', :id => '23'
    should_route :get, "/issues/1/relations/23.xml", :controller => 'issue_relations', :action => 'show', :issue_id => '1', :id => '23', :format => 'xml'
    should_route :get, "/issues/1/relations/23.json", :controller => 'issue_relations', :action => 'show', :issue_id => '1', :id => '23', :format => 'json'

    should_route :delete, "/issues/1/relations/23", :controller => 'issue_relations', :action => 'destroy', :issue_id => '1', :id => '23'
    should_route :delete, "/issues/1/relations/23.xml", :controller => 'issue_relations', :action => 'destroy', :issue_id => '1', :id => '23', :format => 'xml'
    should_route :delete, "/issues/1/relations/23.json", :controller => 'issue_relations', :action => 'destroy', :issue_id => '1', :id => '23', :format => 'json'
  end

  context "issue reports" do
    should_route :get, "/projects/567/issues/report", :controller => 'reports', :action => 'issue_report', :id => '567'
    should_route :get, "/projects/567/issues/report/assigned_to", :controller => 'reports', :action => 'issue_report_details', :id => '567', :detail => 'assigned_to'
  end

  context "news" do
    should_route :get, "/news", :controller => 'news', :action => 'index'
    should_route :get, "/news.atom", :controller => 'news', :action => 'index', :format => 'atom'
    should_route :get, "/news.xml", :controller => 'news', :action => 'index', :format => 'xml'
    should_route :get, "/news.json", :controller => 'news', :action => 'index', :format => 'json'
    should_route :get, "/projects/567/news", :controller => 'news', :action => 'index', :project_id => '567'
    should_route :get, "/projects/567/news.atom", :controller => 'news', :action => 'index', :format => 'atom', :project_id => '567'
    should_route :get, "/projects/567/news.xml", :controller => 'news', :action => 'index', :format => 'xml', :project_id => '567'
    should_route :get, "/projects/567/news.json", :controller => 'news', :action => 'index', :format => 'json', :project_id => '567'
    should_route :get, "/news/2", :controller => 'news', :action => 'show', :id => '2'
    should_route :get, "/projects/567/news/new", :controller => 'news', :action => 'new', :project_id => '567'
    should_route :get, "/news/234", :controller => 'news', :action => 'show', :id => '234'
    should_route :get, "/news/567/edit", :controller => 'news', :action => 'edit', :id => '567'
    should_route :get, "/news/preview", :controller => 'previews', :action => 'news'

    should_route :post, "/projects/567/news", :controller => 'news', :action => 'create', :project_id => '567'
    should_route :post, "/news/567/comments", :controller => 'comments', :action => 'create', :id => '567'

    should_route :put, "/news/567", :controller => 'news', :action => 'update', :id => '567'

    should_route :delete, "/news/567", :controller => 'news', :action => 'destroy', :id => '567'
    should_route :delete, "/news/567/comments/15", :controller => 'comments', :action => 'destroy', :id => '567', :comment_id => '15'
  end

  context "projects" do
    should_route :get, "/projects", :controller => 'projects', :action => 'index'
    should_route :get, "/projects.atom", :controller => 'projects', :action => 'index', :format => 'atom'
    should_route :get, "/projects.xml", :controller => 'projects', :action => 'index', :format => 'xml'
    should_route :get, "/projects/new", :controller => 'projects', :action => 'new'
    should_route :get, "/projects/test", :controller => 'projects', :action => 'show', :id => 'test'
    should_route :get, "/projects/1.xml", :controller => 'projects', :action => 'show', :id => '1', :format => 'xml'
    should_route :get, "/projects/4223/settings", :controller => 'projects', :action => 'settings', :id => '4223'
    should_route :get, "/projects/4223/settings/members", :controller => 'projects', :action => 'settings', :id => '4223', :tab => 'members'
    should_route :get, "/projects/33/files", :controller => 'files', :action => 'index', :project_id => '33'
    should_route :get, "/projects/33/files/new", :controller => 'files', :action => 'new', :project_id => '33'
    should_route :get, "/projects/33/roadmap", :controller => 'versions', :action => 'index', :project_id => '33'
    should_route :get, "/projects/33/activity", :controller => 'activities', :action => 'index', :id => '33'
    should_route :get, "/projects/33/activity.atom", :controller => 'activities', :action => 'index', :id => '33', :format => 'atom'

    should_route :post, "/projects", :controller => 'projects', :action => 'create'
    should_route :post, "/projects.xml", :controller => 'projects', :action => 'create', :format => 'xml'
    should_route :post, "/projects/33/files", :controller => 'files', :action => 'create', :project_id => '33'
    should_route :post, "/projects/64/archive", :controller => 'projects', :action => 'archive', :id => '64'
    should_route :post, "/projects/64/unarchive", :controller => 'projects', :action => 'unarchive', :id => '64'

    should_route :put, "/projects/64/enumerations", :controller => 'project_enumerations', :action => 'update', :project_id => '64'
    should_route :put, "/projects/4223", :controller => 'projects', :action => 'update', :id => '4223'
    should_route :put, "/projects/1.xml", :controller => 'projects', :action => 'update', :id => '1', :format => 'xml'

    should_route :delete, "/projects/64", :controller => 'projects', :action => 'destroy', :id => '64'
    should_route :delete, "/projects/1.xml", :controller => 'projects', :action => 'destroy', :id => '1', :format => 'xml'
    should_route :delete, "/projects/64/enumerations", :controller => 'project_enumerations', :action => 'destroy', :project_id => '64'
  end

  context "queries" do
    should_route :get, "/queries/new", :controller => 'queries', :action => 'new'
    should_route :get, "/projects/redmine/queries/new", :controller => 'queries', :action => 'new', :project_id => 'redmine'

    should_route :post, "/queries/new", :controller => 'queries', :action => 'new'
    should_route :post, "/projects/redmine/queries/new", :controller => 'queries', :action => 'new', :project_id => 'redmine'
  end

  context "queries" do
    should_route :get, "/queries.xml", :controller => 'queries', :action => 'index', :format => 'xml'
    should_route :get, "/queries.json", :controller => 'queries', :action => 'index', :format => 'json'

    should_route :get, "/queries/new", :controller => 'queries', :action => 'new'
    should_route :get, "/projects/redmine/queries/new", :controller => 'queries', :action => 'new', :project_id => 'redmine'

    should_route :post, "/queries", :controller => 'queries', :action => 'create'
    should_route :post, "/projects/redmine/queries", :controller => 'queries', :action => 'create', :project_id => 'redmine'

    should_route :get, "/queries/1/edit", :controller => 'queries', :action => 'edit', :id => '1'
    should_route :get, "/projects/redmine/queries/1/edit", :controller => 'queries', :action => 'edit', :id => '1', :project_id => 'redmine'

    should_route :put, "/queries/1", :controller => 'queries', :action => 'update', :id => '1'
    should_route :put, "/projects/redmine/queries/1", :controller => 'queries', :action => 'update', :id => '1', :project_id => 'redmine'

    should_route :delete, "/queries/1", :controller => 'queries', :action => 'destroy', :id => '1'
    should_route :delete, "/projects/redmine/queries/1", :controller => 'queries', :action => 'destroy', :id => '1', :project_id => 'redmine'
  end

  context "roles" do
    should_route :get, "/roles", :controller => 'roles', :action => 'index'
    should_route :get, "/roles/new", :controller => 'roles', :action => 'new'
    should_route :post, "/roles", :controller => 'roles', :action => 'create'
    should_route :get, "/roles/2/edit", :controller => 'roles', :action => 'edit', :id => 2
    should_route :put, "/roles/2", :controller => 'roles', :action => 'update', :id => 2
    should_route :delete, "/roles/2", :controller => 'roles', :action => 'destroy', :id => 2
    should_route :get, "/roles/permissions", :controller => 'roles', :action => 'permissions'
    should_route :post, "/roles/permissions", :controller => 'roles', :action => 'permissions'
  end

  context "timelogs (global)" do
    should_route :get, "/time_entries", :controller => 'timelog', :action => 'index'
    should_route :get, "/time_entries.csv", :controller => 'timelog', :action => 'index', :format => 'csv'
    should_route :get, "/time_entries.atom", :controller => 'timelog', :action => 'index', :format => 'atom'
    should_route :get, "/time_entries/new", :controller => 'timelog', :action => 'new'
    should_route :get, "/time_entries/22/edit", :controller => 'timelog', :action => 'edit', :id => '22'

    should_route :post, "/time_entries", :controller => 'timelog', :action => 'create'

    should_route :put, "/time_entries/22", :controller => 'timelog', :action => 'update', :id => '22'

    should_route :delete, "/time_entries/55", :controller => 'timelog', :action => 'destroy', :id => '55'
  end

  context "timelogs (scoped under project)" do
    should_route :get, "/projects/567/time_entries", :controller => 'timelog', :action => 'index', :project_id => '567'
    should_route :get, "/projects/567/time_entries.csv", :controller => 'timelog', :action => 'index', :project_id => '567', :format => 'csv'
    should_route :get, "/projects/567/time_entries.atom", :controller => 'timelog', :action => 'index', :project_id => '567', :format => 'atom'
    should_route :get, "/projects/567/time_entries/new", :controller => 'timelog', :action => 'new', :project_id => '567'
    should_route :get, "/projects/567/time_entries/22/edit", :controller => 'timelog', :action => 'edit', :id => '22', :project_id => '567'

    should_route :post, "/projects/567/time_entries", :controller => 'timelog', :action => 'create', :project_id => '567'

    should_route :put, "/projects/567/time_entries/22", :controller => 'timelog', :action => 'update', :id => '22', :project_id => '567'

    should_route :delete, "/projects/567/time_entries/55", :controller => 'timelog', :action => 'destroy', :id => '55', :project_id => '567'
  end

  context "timelogs (scoped under issues)" do
    should_route :get, "/issues/234/time_entries", :controller => 'timelog', :action => 'index', :issue_id => '234'
    should_route :get, "/issues/234/time_entries.csv", :controller => 'timelog', :action => 'index', :issue_id => '234', :format => 'csv'
    should_route :get, "/issues/234/time_entries.atom", :controller => 'timelog', :action => 'index', :issue_id => '234', :format => 'atom'
    should_route :get, "/issues/234/time_entries/new", :controller => 'timelog', :action => 'new', :issue_id => '234'
    should_route :get, "/issues/234/time_entries/22/edit", :controller => 'timelog', :action => 'edit', :id => '22', :issue_id => '234'

    should_route :post, "/issues/234/time_entries", :controller => 'timelog', :action => 'create', :issue_id => '234'

    should_route :put, "/issues/234/time_entries/22", :controller => 'timelog', :action => 'update', :id => '22', :issue_id => '234'

    should_route :delete, "/issues/234/time_entries/55", :controller => 'timelog', :action => 'destroy', :id => '55', :issue_id => '234'
  end

  context "timelogs (scoped under project and issues)" do
    should_route :get, "/projects/ecookbook/issues/234/time_entries", :controller => 'timelog', :action => 'index', :issue_id => '234', :project_id => 'ecookbook'
    should_route :get, "/projects/ecookbook/issues/234/time_entries.csv", :controller => 'timelog', :action => 'index', :issue_id => '234', :project_id => 'ecookbook', :format => 'csv'
    should_route :get, "/projects/ecookbook/issues/234/time_entries.atom", :controller => 'timelog', :action => 'index', :issue_id => '234', :project_id => 'ecookbook', :format => 'atom'
    should_route :get, "/projects/ecookbook/issues/234/time_entries/new", :controller => 'timelog', :action => 'new', :issue_id => '234', :project_id => 'ecookbook'
    should_route :get, "/projects/ecookbook/issues/234/time_entries/22/edit", :controller => 'timelog', :action => 'edit', :id => '22', :issue_id => '234', :project_id => 'ecookbook'

    should_route :post, "/projects/ecookbook/issues/234/time_entries", :controller => 'timelog', :action => 'create', :issue_id => '234', :project_id => 'ecookbook'

    should_route :put, "/projects/ecookbook/issues/234/time_entries/22", :controller => 'timelog', :action => 'update', :id => '22', :issue_id => '234', :project_id => 'ecookbook'

    should_route :delete, "/projects/ecookbook/issues/234/time_entries/55", :controller => 'timelog', :action => 'destroy', :id => '55', :issue_id => '234', :project_id => 'ecookbook'

    should_route :get, "/time_entries/report", :controller => 'timelog', :action => 'report'
    should_route :get, "/projects/567/time_entries/report", :controller => 'timelog', :action => 'report', :project_id => '567'
    should_route :get, "/projects/567/time_entries/report.csv", :controller => 'timelog', :action => 'report', :project_id => '567', :format => 'csv'
  end

  context "users" do
    should_route :get, "/users", :controller => 'users', :action => 'index'
    should_route :get, "/users.xml", :controller => 'users', :action => 'index', :format => 'xml'
    should_route :get, "/users/44", :controller => 'users', :action => 'show', :id => '44'
    should_route :get, "/users/44.xml", :controller => 'users', :action => 'show', :id => '44', :format => 'xml'
    should_route :get, "/users/current", :controller => 'users', :action => 'show', :id => 'current'
    should_route :get, "/users/current.xml", :controller => 'users', :action => 'show', :id => 'current', :format => 'xml'
    should_route :get, "/users/new", :controller => 'users', :action => 'new'
    should_route :get, "/users/444/edit", :controller => 'users', :action => 'edit', :id => '444'

    should_route :post, "/users", :controller => 'users', :action => 'create'
    should_route :post, "/users.xml", :controller => 'users', :action => 'create', :format => 'xml'

    should_route :put, "/users/444", :controller => 'users', :action => 'update', :id => '444'
    should_route :put, "/users/444.xml", :controller => 'users', :action => 'update', :id => '444', :format => 'xml'

    should_route :delete, "/users/44", :controller => 'users', :action => 'destroy', :id => '44'
    should_route :delete, "/users/44.xml", :controller => 'users', :action => 'destroy', :id => '44', :format => 'xml'

    should_route :post, "/users/123/memberships", :controller => 'users', :action => 'edit_membership', :id => '123'
    should_route :put, "/users/123/memberships/55", :controller => 'users', :action => 'edit_membership', :id => '123', :membership_id => '55'
    should_route :delete, "/users/123/memberships/55", :controller => 'users', :action => 'destroy_membership', :id => '123', :membership_id => '55'
  end

  context "versions" do
    # /projects/foo/versions is /projects/foo/roadmap
    should_route :get, "/projects/foo/versions.xml", :controller => 'versions', :action => 'index', :project_id => 'foo', :format => 'xml'
    should_route :get, "/projects/foo/versions.json", :controller => 'versions', :action => 'index', :project_id => 'foo', :format => 'json'

    should_route :get, "/projects/foo/versions/new", :controller => 'versions', :action => 'new', :project_id => 'foo'

    should_route :post, "/projects/foo/versions", :controller => 'versions', :action => 'create', :project_id => 'foo'
    should_route :post, "/projects/foo/versions.xml", :controller => 'versions', :action => 'create', :project_id => 'foo', :format => 'xml'
    should_route :post, "/projects/foo/versions.json", :controller => 'versions', :action => 'create', :project_id => 'foo', :format => 'json'

    should_route :get, "/versions/1", :controller => 'versions', :action => 'show', :id => '1'
    should_route :get, "/versions/1.xml", :controller => 'versions', :action => 'show', :id => '1', :format => 'xml'
    should_route :get, "/versions/1.json", :controller => 'versions', :action => 'show', :id => '1', :format => 'json'

    should_route :get, "/versions/1/edit", :controller => 'versions', :action => 'edit', :id => '1'

    should_route :put, "/versions/1", :controller => 'versions', :action => 'update', :id => '1'
    should_route :put, "/versions/1.xml", :controller => 'versions', :action => 'update', :id => '1', :format => 'xml'
    should_route :put, "/versions/1.json", :controller => 'versions', :action => 'update', :id => '1', :format => 'json'

    should_route :delete, "/versions/1", :controller => 'versions', :action => 'destroy', :id => '1'
    should_route :delete, "/versions/1.xml", :controller => 'versions', :action => 'destroy', :id => '1', :format => 'xml'
    should_route :delete, "/versions/1.json", :controller => 'versions', :action => 'destroy', :id => '1', :format => 'json'

    should_route :put, "/projects/foo/versions/close_completed", :controller => 'versions', :action => 'close_completed', :project_id => 'foo'
    should_route :post, "/versions/1/status_by", :controller => 'versions', :action => 'status_by', :id => '1'
  end

  context "welcome" do
    should_route :get, "/robots.txt", :controller => 'welcome', :action => 'robots'
  end

  context "wiki (singular, project's pages)" do
    should_route :get, "/projects/567/wiki", :controller => 'wiki', :action => 'show', :project_id => '567'
    should_route :get, "/projects/567/wiki/lalala", :controller => 'wiki', :action => 'show', :project_id => '567', :id => 'lalala'
    should_route :get, "/projects/567/wiki/my_page/edit", :controller => 'wiki', :action => 'edit', :project_id => '567', :id => 'my_page'
    should_route :get, "/projects/1/wiki/CookBook_documentation/history", :controller => 'wiki', :action => 'history', :project_id => '1', :id => 'CookBook_documentation'
    should_route :get, "/projects/1/wiki/CookBook_documentation/diff", :controller => 'wiki', :action => 'diff', :project_id => '1', :id => 'CookBook_documentation'
    should_route :get, "/projects/1/wiki/CookBook_documentation/diff/2", :controller => 'wiki', :action => 'diff', :project_id => '1', :id => 'CookBook_documentation', :version => '2'
    should_route :get, "/projects/1/wiki/CookBook_documentation/diff/2/vs/1", :controller => 'wiki', :action => 'diff', :project_id => '1', :id => 'CookBook_documentation', :version => '2', :version_from => '1'
    should_route :get, "/projects/1/wiki/CookBook_documentation/annotate/2", :controller => 'wiki', :action => 'annotate', :project_id => '1', :id => 'CookBook_documentation', :version => '2'
    should_route :get, "/projects/22/wiki/ladida/rename", :controller => 'wiki', :action => 'rename', :project_id => '22', :id => 'ladida'
    should_route :get, "/projects/567/wiki/index", :controller => 'wiki', :action => 'index', :project_id => '567'
    should_route :get, "/projects/567/wiki/date_index", :controller => 'wiki', :action => 'date_index', :project_id => '567'
    should_route :get, "/projects/567/wiki/export", :controller => 'wiki', :action => 'export', :project_id => '567'

    should_route :post, "/projects/567/wiki/CookBook_documentation/preview", :controller => 'wiki', :action => 'preview', :project_id => '567', :id => 'CookBook_documentation'
    should_route :post, "/projects/22/wiki/ladida/rename", :controller => 'wiki', :action => 'rename', :project_id => '22', :id => 'ladida'
    should_route :post, "/projects/22/wiki/ladida/protect", :controller => 'wiki', :action => 'protect', :project_id => '22', :id => 'ladida'
    should_route :post, "/projects/22/wiki/ladida/add_attachment", :controller => 'wiki', :action => 'add_attachment', :project_id => '22', :id => 'ladida'

    should_route :put, "/projects/567/wiki/my_page", :controller => 'wiki', :action => 'update', :project_id => '567', :id => 'my_page'

    should_route :delete, "/projects/22/wiki/ladida", :controller => 'wiki', :action => 'destroy', :project_id => '22', :id => 'ladida'
  end

  context "wikis (plural, admin setup)" do
    should_route :get, "/projects/ladida/wiki/destroy", :controller => 'wikis', :action => 'destroy', :id => 'ladida'

    should_route :post, "/projects/ladida/wiki", :controller => 'wikis', :action => 'edit', :id => 'ladida'
    should_route :post, "/projects/ladida/wiki/destroy", :controller => 'wikis', :action => 'destroy', :id => 'ladida'
  end

  context "auto_completes" do
    should_route :get, "/users/auto_complete", :controller => 'auto_completes', :action => 'users'
  end
end
