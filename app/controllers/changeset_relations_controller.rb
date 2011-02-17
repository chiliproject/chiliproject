class ChangesetRelationsController < ApplicationController
  
  
  before_filter  :find_project, :authorize
  
  def new
    @changeset = Changeset.find(:first, :conditions => {:revision => params[:changeset][:revision], :repository_id => @project.repository})
    if @changeset.nil?
      @changeset = Changeset.new(:revision => params[:changeset][:revision])
      @changeset.errors.add('revision_not_found_error', '')
    else
      @changeset.issues << @issue
      @changeset.save if request.post?
    end
    @issue.reload
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js do
        render :update do |page|
          page.replace_html "issue-changesets-list", :partial => 'issues/changesets', :locals => { :changesets => @issue.changesets }
          if @changeset.errors.empty?
            page << "$('changeset_revision').value = ''"
          end
        end
      end
    end
  end
  
  def destroy
    changeset = Changeset.find(params[:id])
    if request.post? && ! changeset.nil? && changeset.issues.include?(@issue)
      changeset.issues.delete(@issue)
      @issue.reload
    end
    respond_to do |format|
      format.html { redirect_to :controller => 'issues', :action => 'show', :id => @issue }
      format.js do
        render(:update) do |page|
          page.replace_html "issue-changesets-list", :partial => 'issues/changesets', :locals => { :changesets => @issue.changesets }
        end
      end
    end
  end
  
  
  private
  
  def find_project
    @issue = Issue.find(params[:issue_id])
    @project = @issue.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end
  
end
