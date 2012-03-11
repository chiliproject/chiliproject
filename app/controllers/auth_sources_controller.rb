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

class AuthSourcesController < ApplicationController
  layout 'admin'
  menu_item :ldap_authentication

  before_filter :require_admin

  def index
    @auth_source_pages, @auth_sources = paginate AuthSource, :per_page => 10
  end

  def new
    klass_name = params[:type] || 'AuthSourceLdap'
    @auth_source = AuthSource.new_subclass_instance(klass_name, params[:auth_source])
  end

  def create
    @auth_source = AuthSource.new_subclass_instance(params[:type], params[:auth_source])
    if @auth_source.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index'
    else
      render :action => 'new'
    end
  end

  def edit
    @auth_source = AuthSource.find(params[:id])
  end

  def update
    @auth_source = AuthSource.find(params[:id])
    if @auth_source.update_attributes(params[:auth_source])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index'
    else
      render :action => 'edit'
    end
  end

  def test_connection
    @auth_source = AuthSource.find(params[:id])
    begin
      @auth_source.test_connection
      flash[:notice] = l(:notice_successful_connection)
    rescue Exception => e
      flash[:error] = l(:error_unable_to_connect, e.message)
    end
    redirect_to :action => 'index'
  end

  def destroy
    @auth_source = AuthSource.find(params[:id])
    unless @auth_source.users.find(:first)
      @auth_source.destroy
      flash[:notice] = l(:notice_successful_delete)
    end
    redirect_to :action => 'index'
  end
end
