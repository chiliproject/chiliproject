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

class DocumentsController < ApplicationController
  default_search_scope :documents
  model_object Document
  before_filter :find_project, :only => [:index, :new]
  before_filter :find_model_object, :except => [:index, :new]
  before_filter :find_project_from_association, :except => [:index, :new]
  before_filter :authorize


  def index
    @sort_by = %w(category date title author).include?(params[:sort_by]) ? params[:sort_by] : 'category'
    documents = @project.documents.find :all, :include => [:attachments, :category]
    case @sort_by
    when 'date'
      @grouped = documents.group_by {|d| d.updated_on.to_date }
    when 'title'
      @grouped = documents.group_by {|d| d.title.first.upcase}
    when 'author'
      @grouped = documents.select{|d| d.attachments.any?}.group_by {|d| d.attachments.last.author}
    else
      @grouped = documents.group_by(&:category)
    end
    @document = @project.documents.build
    render :layout => false if request.xhr?
  end

  def show
    @attachments = @document.attachments.find(:all, :order => "created_on DESC")
  end

  def new
    @document = @project.documents.build
    @document.safe_attributes = params[:document]
    if request.post?
      if User.current.allowed_to?(:add_document_watchers, @project) && params[:document]['watcher_user_ids'].present?
        @document.watcher_user_ids = params[:document]['watcher_user_ids']
      end

      if @document.save
        attachments = Attachment.attach_files(@document, params[:attachments])
        render_attachment_warning_if_needed(@document)
        flash[:notice] = l(:notice_successful_create)
        redirect_to :action => 'index', :project_id => @project
      end
    end
  end

  def edit
    @categories = DocumentCategory.all

    if request.post?
      if User.current.allowed_to?(:add_document_watchers, @project) && params[:document]['watcher_user_ids'].present?
        @document.watcher_user_ids = params[:document]['watcher_user_ids']
      end

      if @document.update_attributes(params[:document])
        flash[:notice] = l(:notice_successful_update)
        redirect_to :action => 'show', :id => @document
      end
    end
  end

  def destroy
    @document.destroy
    redirect_to :controller => 'documents', :action => 'index', :project_id => @project
  end

  def add_attachment
    attachments = Attachment.attach_files(@document, params[:attachments])
    render_attachment_warning_if_needed(@document)

    if attachments.present? && attachments[:files].present? && Setting.notified_events.include?('document_added')
      # TODO: refactor
      @document.recipients.each do |recipient|
        Mailer.deliver_attachments_added(attachments[:files], recipient)
      end
    end
    redirect_to :action => 'show', :id => @document
  end

private
  def find_project
    @project = Project.find(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
