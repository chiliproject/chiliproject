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

    should_route :post, "/projects", :controller => 'projects', :action => 'create'
    should_route :post, "/projects.xml", :controller => 'projects', :action => 'create', :format => 'xml'
    should_route :post, "/projects/64/archive", :controller => 'projects', :action => 'archive', :id => '64'
    should_route :post, "/projects/64/unarchive", :controller => 'projects', :action => 'unarchive', :id => '64'

    should_route :put, "/projects/4223", :controller => 'projects', :action => 'update', :id => '4223'
    should_route :put, "/projects/1.xml", :controller => 'projects', :action => 'update', :id => '1', :format => 'xml'

    should_route :delete, "/projects/64", :controller => 'projects', :action => 'destroy', :id => '64'
    should_route :delete, "/projects/1.xml", :controller => 'projects', :action => 'destroy', :id => '1', :format => 'xml'
  end
end
