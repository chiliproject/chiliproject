#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class WikisController < ApplicationController
  menu_item :settings
  before_filter :find_project, :authorize

  # Create or update a project's wiki
  def edit
    @wiki = @project.wiki || Wiki.new(:project => @project)
    @wiki.safe_attributes = params[:wiki]
    @wiki.save if request.post?
    render(:update) {|page| page.replace_html "tab-content-wiki", :partial => 'projects/settings/wiki'}
  end

  # Delete a project's wiki
  def destroy
    if request.post? && params[:confirm] && @project.wiki
      @project.wiki.destroy
      redirect_to :controller => 'projects', :action => 'settings', :id => @project, :tab => 'wiki'
    end
  end
end
