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

class CustomFieldsController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  before_filter :build_new_custom_field, :only => [:new, :create]
  before_filter :find_custom_field, :only => [:edit, :update, :destroy]

  def index
    @custom_fields_by_type = CustomField.find(:all).group_by {|f| f.class.name }
    @tab = params[:tab] || 'IssueCustomField'
  end

  def new
  end

  def create
    if request.post? and @custom_field.save
      flash[:notice] = l(:notice_successful_create)
      call_hook(:controller_custom_fields_new_after_save, :params => params, :custom_field => @custom_field)
      redirect_to :action => 'index', :tab => @custom_field.class.name
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if request.put? and @custom_field.update_attributes(params[:custom_field])
      flash[:notice] = l(:notice_successful_update)
      call_hook(:controller_custom_fields_edit_after_save, :params => params, :custom_field => @custom_field)
      redirect_to :action => 'index', :tab => @custom_field.class.name
    else
      render :action => 'edit'
    end
  end

  def destroy
    @custom_field.destroy
    redirect_to :action => 'index', :tab => @custom_field.class.name
  rescue
    flash[:error] = l(:error_can_not_delete_custom_field)
    redirect_to :action => 'index'
  end

  private

  def build_new_custom_field
    @custom_field = CustomField.new_subclass_instance(params[:type], params[:custom_field])
    if @custom_field.nil?
      render_404
    end
  end

  def find_custom_field
    @custom_field = CustomField.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
