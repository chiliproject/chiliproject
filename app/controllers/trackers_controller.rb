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

class TrackersController < ApplicationController
  layout 'admin'

  before_filter :require_admin

  def index
    @tracker_pages, @trackers = paginate :trackers, :per_page => 10, :order => 'position'
    render :action => "index", :layout => false if request.xhr?
  end

  def new
    @tracker ||= Tracker.new(params[:tracker])
    @trackers = Tracker.find :all, :order => 'position'
    @projects = Project.find(:all)
  end

  def create
    @tracker = Tracker.new(params[:tracker])
    if request.post? and @tracker.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Tracker.find_by_id(params[:copy_workflow_from]))
        @tracker.workflows.copy(copy_from)
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
      return
    end
    new
    render :action => 'new'
  end

  def edit
    @tracker ||= Tracker.find(params[:id])
    @projects = Project.find(:all)
  end
  
  def update
    @tracker = Tracker.find(params[:id])
    if request.put? and @tracker.update_attributes(params[:tracker])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
      return
    end
    edit
    render :action => 'edit'
  end

  verify :method => :delete, :only => :destroy, :redirect_to => { :action => :index }
  def destroy
    @tracker = Tracker.find(params[:id])
    unless @tracker.issues.empty?
      flash[:error] = l(:error_can_not_delete_tracker)
    else
      @tracker.destroy
    end
    redirect_to :action => 'index'
  end
end
