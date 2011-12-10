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

class IssueRelationsController < ApplicationController
  before_filter :find_issue, :find_project_from_association, :authorize
  accept_key_auth :show, :create, :destroy

  def show
    @relation = @issue.find_relation(params[:id])
    respond_to do |format|
      format.html { render :nothing => true }
      format.api
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  verify :method => :post, :only => :create, :render => {:nothing => true, :status => :method_not_allowed }
  def create
    @relation = IssueRelation.new(params[:relation])
    @relation.issue_from = @issue
    if params[:relation] && m = params[:relation][:issue_to_id].to_s.match(/^#?(\d+)$/)
      @relation.issue_to = Issue.visible.find_by_id(m[1].to_i)
    end
    saved = @relation.save

    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js do
        @relations = @issue.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
        render :update do |page|
          page.replace_html "relations", :partial => 'issues/relations'
          if @relation.errors.empty?
            page << "$('relation_delay').value = ''"
            page << "$('relation_issue_to_id').value = ''"
          end
        end
      end
      format.api {
        if saved
          render :action => 'show', :status => :created, :location => issue_relation_url(@issue, @relation)
        else
          render_validation_errors(@relation)
        end
      }
    end
  end

  verify :method => :delete, :only => :destroy, :render => {:nothing => true, :status => :method_not_allowed }
  def destroy
    relation = @issue.find_relation(params[:id])
    relation.destroy

    respond_to do |format|
      # TODO : does this really work since @issue is always nil? What is it useful to?
      format.html { redirect_to issue_path }
      format.js {
        @relations = @issue.reload.relations.select {|r| r.other_issue(@issue) && r.other_issue(@issue).visible? }
        render(:update) {|page| page.replace_html "relations", :partial => 'issues/relations'}
      }
      format.api { head :ok }
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

private
  def find_issue
    @issue = @object = Issue.find(params[:issue_id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end
