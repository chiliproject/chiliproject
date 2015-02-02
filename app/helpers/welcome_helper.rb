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

module WelcomeHelper
  def project_sublinks(project, modules=[])
    html = ""
    html += " | #{link_to l(:label_issue_plural), :controller => 'issues', :action => 'index', :project_id => project } " if modules.include?("issue_tracking")
    html += " | #{link_to l(:label_time_tracking), :controller => 'timelog', :action => 'index', :project_id => project } " if modules.include?("time_tracking")
    html += " | #{link_to l(:label_news), :controller => 'news', :action => 'index', :project_id => project } " if modules.include?("news")
    html += " | #{link_to l(:label_document_plural), :controller => 'documents', :action => 'index', :id => project } " if modules.include?("documents")
    html += " | #{link_to l(:label_file_plural), :controller => 'files', :action => 'index', :project_id => project } " if modules.include?("files")
    html += " | #{link_to l(:label_wiki), :controller => 'wiki', :action => 'show', :project_id => project } " if modules.include?("wiki")
    html += " | #{link_to l(:label_repository), :controller => 'repositories', :action => 'show', :id => project } " if modules.include?("repository")
    html += " | #{link_to l(:label_board), :controller => 'boards', :action => 'index', :project_id => project } " if modules.include?("boards")
    html += " | #{link_to l(:label_calendar), :controller => 'calendars', :action => 'show', :project_id => project } " if modules.include?("calendar")
    html += " | #{link_to l(:label_gantt), :controller => 'gantts', :action => 'show', :project_id => project } " if modules.include?("gantt")
    html += " |" unless html.empty?
    return html
  end
end
