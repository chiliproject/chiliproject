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

class WelcomeController < ApplicationController
  caches_action :robots

  def index
    @news = News.latest User.current
    @latest_projects = Project.latest User.current

    visible_projects = Project.visible().find(:all, :order => "projects.name")
    @admin_projects = []
    @my_projects = []

    visible_projects.each do |project|
      if User.current.member_of?(project)
        @my_projects << project
      else
        @admin_projects << project
      end
    end
  end

  def robots
    @projects = Project.all_public.active
    render :layout => false, :content_type => 'text/plain'
  end
end
