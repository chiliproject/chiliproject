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

class RolesController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  before_filter :find_role, :only => [:edit, :update, :destroy]

  def index
    @role_pages, @roles = paginate :roles, :per_page => 25, :order => 'builtin, position'
    render :action => "index", :layout => false if request.xhr?
  end

  def new
    # Prefills the form with 'Non member' role permissions
    @role = Role.new(params[:role] || {:permissions => Role.non_member.permissions})
    @roles = Role.sorted.all
  end

  def create
    @role = Role.new(params[:role])
    if request.post? && @role.save
      # workflow copy
      if !params[:copy_workflow_from].blank? && (copy_from = Role.find_by_id(params[:copy_workflow_from]))
        @role.workflows.copy(copy_from)
      end
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      @roles = Role.sorted.all
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if request.put? and @role.update_attributes(params[:role])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  verify :method => :delete, :only => :destroy, :redirect_to => { :action => :index }
  def destroy
    @role.destroy
    redirect_to :action => 'index'
  rescue
    flash[:error] =  l(:error_can_not_remove_role)
    redirect_to :action => 'index'
  end

  def permissions
    @roles = Role.sorted.all
    @permissions = Redmine::AccessControl.permissions.select { |p| !p.public? }
    if request.post?
      @roles.each do |role|
        role.permissions = params[:permissions][role.id.to_s]
        role.save
      end
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    end
  end

  private

  def find_role
    @role = Role.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
