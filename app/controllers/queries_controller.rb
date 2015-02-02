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

class QueriesController < ApplicationController
  menu_item :issues
  before_filter :find_query, :except => [:new, :create, :index]
  before_filter :find_optional_project, :only => [:new, :create]

  accept_key_auth :index

  include QueriesHelper

  def index
    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    @query_count = Query.visible.count
    @query_pages = Paginator.new self, @query_count, @limit, params['page']
    @queries = Query.visible.all(:limit => @limit, :offset => @offset, :order => "#{Query.table_name}.name")

    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  end

  def new
    @query = Query.new
    @query.user = User.current
    @query.project = @project
    @query.is_public = false unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    build_query_from_params
  end

  def create
    @query = Query.new(params[:query])
    @query.display_subprojects = params[:display_subprojects] if params[:display_subprojects].present?
    @query.user = User.current
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.is_public = false unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    build_query_from_params
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :controller => 'issues', :action => 'index', :project_id => @project, :query_id => @query
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    @query.attributes = params[:query]
    @query.project = nil if params[:query_is_for_all]
    @query.display_subprojects = params[:display_subprojects] if params[:display_subprojects].present?
    @query.is_public = false unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    build_query_from_params
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to :controller => 'issues', :action => 'index', :project_id => @project, :query_id => @query
    else
      render :action => 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to :controller => 'issues', :action => 'index', :project_id => @project, :set_filter => 1
  end

private
  def find_query
    @query = Query.find(params[:id])
    @project = @query.project
    render_403 unless @query.editable_by?(User.current)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project
    @project = Project.find(params[:project_id]) if params[:project_id]
    render_403 unless User.current.allowed_to?(:save_queries, @project, :global => true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
