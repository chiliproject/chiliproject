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

class EnumerationsController < ApplicationController
  layout 'admin'

  before_filter :require_admin
  before_filter :build_new_enumeration, :only => [:new, :create]
  before_filter :find_enumeration, :only => [:edit, :update, :destroy]

  def index
  end

  def new
  end

  def create
    if request.post? && @enumeration.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to :action => 'index', :type => @enumeration.type
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if request.put? && @enumeration.update_attributes(params[:enumeration])
      flash[:notice] = l(:notice_successful_update)
      redirect_to :action => 'index', :type => @enumeration.type
    else
      render :action => 'edit'
    end
  end

  def destroy
    if !@enumeration.in_use?
      # No associated objects
      @enumeration.destroy
      redirect_to :action => 'index'
      return
    elsif params[:reassign_to_id]
      if reassign_to = @enumeration.class.find_by_id(params[:reassign_to_id])
        @enumeration.destroy(reassign_to)
        redirect_to :action => 'index'
        return
      end
    end
    @enumerations = @enumeration.class.all - [@enumeration]
  end

  private

  def build_new_enumeration
    class_name = params[:enumeration] && params[:enumeration][:type] || params[:type]
    @enumeration = Enumeration.new_subclass_instance(class_name, params[:enumeration])
    if @enumeration.nil?
      render_404
    end
  end

  def find_enumeration
    @enumeration = Enumeration.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
