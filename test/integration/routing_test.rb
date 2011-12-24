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
  context "projects" do
    should_route :get, "/projects", :controller => 'projects', :action => 'index'
    should_route :get, "/projects.atom", :controller => 'projects', :action => 'index', :format => 'atom'
    should_route :get, "/projects.xml", :controller => 'projects', :action => 'index', :format => 'xml'
    should_route :get, "/projects/new", :controller => 'projects', :action => 'new'
    should_route :get, "/projects/test", :controller => 'projects', :action => 'show', :id => 'test'
    should_route :get, "/projects/1.xml", :controller => 'projects', :action => 'show', :id => '1', :format => 'xml'
    should_route :get, "/projects/4223/settings", :controller => 'projects', :action => 'settings', :id => '4223'
    should_route :get, "/projects/4223/settings/members", :controller => 'projects', :action => 'settings', :id => '4223', :tab => 'members'
    should_route :get, "/projects/33/roadmap", :controller => 'versions', :action => 'index', :project_id => '33'

    should_route :post, "/projects", :controller => 'projects', :action => 'create'
    should_route :post, "/projects.xml", :controller => 'projects', :action => 'create', :format => 'xml'
    should_route :post, "/projects/64/archive", :controller => 'projects', :action => 'archive', :id => '64'
    should_route :post, "/projects/64/unarchive", :controller => 'projects', :action => 'unarchive', :id => '64'

    should_route :put, "/projects/4223", :controller => 'projects', :action => 'update', :id => '4223'
    should_route :put, "/projects/1.xml", :controller => 'projects', :action => 'update', :id => '1', :format => 'xml'

    should_route :delete, "/projects/64", :controller => 'projects', :action => 'destroy', :id => '64'
    should_route :delete, "/projects/1.xml", :controller => 'projects', :action => 'destroy', :id => '1', :format => 'xml'
  end

  context "queries" do
    should_route :get, "/queries.xml", :controller => 'queries', :action => 'index', :format => 'xml'
    should_route :get, "/queries.json", :controller => 'queries', :action => 'index', :format => 'json'

    should_route :get, "/queries/new", :controller => 'queries', :action => 'new'
    should_route :get, "/projects/redmine/queries/new", :controller => 'queries', :action => 'new', :project_id => 'redmine'

    should_route :post, "/queries", :controller => 'queries', :action => 'create'
    should_route :post, "/projects/redmine/queries", :controller => 'queries', :action => 'create', :project_id => 'redmine'

    should_route :get, "/queries/1/edit", :controller => 'queries', :action => 'edit', :id => '1'

    should_route :put, "/queries/1", :controller => 'queries', :action => 'update', :id => '1'

    should_route :delete, "/queries/1", :controller => 'queries', :action => 'destroy', :id => '1'
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
end
