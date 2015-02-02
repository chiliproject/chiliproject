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

class SysController < ActionController::Base
  before_filter :check_enabled
  before_filter :cached_basic_auth, :only => [:auth]

  # TODO: We should probably fully disable sessions here

  def projects
    p = Project.active.has_module(:repository).find(:all, :include => :repository, :order => 'identifier')
    render :xml => p.to_xml(:include => :repository)
  end

  def create_project_repository
    project = Project.find(params[:id])
    if project.repository
      render :nothing => true, :status => 409
    else
      logger.info "Repository for #{project.name} was reported to be created by #{request.remote_ip}."
      project.repository = Repository.factory(params[:vendor], params[:repository])
      if project.repository && project.repository.save
        render :xml => project.repository, :status => 201
      else
        render :nothing => true, :status => 422
      end
    end
  end

  # Check a user's permission on a project. The requested permission must be
  # given as a parameter
  #
  # Returns HTTP 200 when the user has the permission
  # Returns HTTP 401 when the user could not be authenticated
  # Returns HTTP 403 when the user was correctly authenticated but does not have the permission
  # Returns HTTP 404 when a parameter was missing or invalid
  def auth
    project = Project.find(params[:id])
    permission = params[:permission] || raise(ActiveRecord::RecordNotFound)

    if User.current.allowed_to?(permission.to_sym, project)
      render :text => "Access granted"
    else
      render :text => "Not allowed", :status => 403 # default to deny
    end
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

  def fetch_changesets
    projects = []
    if params[:id]
      projects << Project.active.has_module(:repository).find(params[:id])
    else
      projects = Project.active.has_module(:repository).find(:all, :include => :repository)
    end
    projects.each do |project|
      if project.repository
        project.repository.fetch_changesets
      end
    end
    render :nothing => true, :status => 200
  rescue ActiveRecord::RecordNotFound
    render :nothing => true, :status => 404
  end

  protected

  def check_enabled
    User.current = nil
    unless Setting.sys_api_enabled? && params[:key].to_s == Setting.sys_api_key
      render :text => 'Access denied. Repository management WS is disabled or key is invalid.', :status => 403
      return false
    end
  end

  def cached_basic_auth
    User.current = authenticate_or_request_with_http_basic do |login, password|
      User.try_to_login(login, password, :cached => true)
    end
  end
end
