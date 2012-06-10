#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'redmine/access_control'
require 'redmine/menu_manager'
require 'redmine/activity'
require 'redmine/search'
require 'redmine/custom_field_format'
require 'redmine/mime_type'
require 'redmine/core_ext'
require 'redmine/themes'
require 'redmine/hook'
require 'redmine/plugin'
require 'redmine/notifiable'
require 'redmine/wiki_formatting'
require 'redmine/scm/base'

begin
  require_library_or_gem 'RMagick' unless Object.const_defined?(:Magick)
rescue LoadError
  # RMagick is not available
end

if RUBY_VERSION < '1.9'
  require 'faster_csv'
else
  require 'csv'
  FCSV = CSV
end

Redmine::Scm::Base.add "Subversion"
Redmine::Scm::Base.add "Darcs"
Redmine::Scm::Base.add "Mercurial"
Redmine::Scm::Base.add "Cvs"
Redmine::Scm::Base.add "Bazaar"
Redmine::Scm::Base.add "Git"
Redmine::Scm::Base.add "Filesystem"

Redmine::CustomFieldFormat.map do |fields|
  fields.register Redmine::CustomFieldFormat.new('string', :label => :label_string, :order => 1)
  fields.register Redmine::CustomFieldFormat.new('text', :label => :label_text, :order => 2)
  fields.register Redmine::CustomFieldFormat.new('int', :label => :label_integer, :order => 3)
  fields.register Redmine::CustomFieldFormat.new('float', :label => :label_float, :order => 4)
  fields.register Redmine::CustomFieldFormat.new('list', :label => :label_list, :order => 5)
  fields.register Redmine::CustomFieldFormat.new('date', :label => :label_date, :order => 6)
  fields.register Redmine::CustomFieldFormat.new('bool', :label => :label_boolean, :order => 7)
  fields.register Redmine::CustomFieldFormat.new('user', :label => :label_user, :only => %w(Issue TimeEntry Version Project), :edit_as => 'list', :order => 8)
  fields.register Redmine::CustomFieldFormat.new('version', :label => :label_version, :only => %w(Issue TimeEntry Version Project), :edit_as => 'list', :order => 9)
end

# Permissions
Redmine::AccessControl.map do |map|
  map.permission :view_project, {:projects => [:show], :activities => [:index]}, :public => true
  map.permission :search_project, {:search => :index}, :public => true
  map.permission :add_project, {:projects => [:new, :create]}, :require => :loggedin
  map.permission :edit_project, {:projects => [:settings, :edit, :update]}, :require => :member
  map.permission :select_project_modules, {:projects => :modules}, :require => :member
  map.permission :manage_members, {:projects => :settings, :members => [:new, :edit, :destroy, :autocomplete_for_member]}, :require => :member
  map.permission :manage_versions, {:projects => :settings, :versions => [:new, :create, :edit, :update, :close_completed, :destroy]}, :require => :member
  map.permission :add_subprojects, {:projects => [:new, :create]}, :require => :member

  map.project_module :issue_tracking do |map|
    # Issue categories
    map.permission :manage_categories, {:projects => :settings, :issue_categories => [:new, :edit, :destroy]}, :require => :member
    # Issues
    map.permission :view_issues, {:issues => [:index, :show],
                                  :auto_complete => [:issues],
                                  :context_menus => [:issues],
                                  :versions => [:index, :show, :status_by],
                                  :journals => [:index, :diff],
                                  :queries => :index,
                                  :reports => [:issue_report, :issue_report_details]}
    map.permission :add_issues, {:issues => [:new, :create, :update_form]}
    map.permission :edit_issues, {:issues => [:edit, :update, :bulk_edit, :bulk_update, :update_form], :journals => [:new]}
    map.permission :manage_issue_relations, {:issue_relations => [:new, :destroy]}
    map.permission :manage_subtasks, {}
    map.permission :add_issue_notes, {:issues => [:edit, :update], :journals => [:new]}
    map.permission :edit_issue_notes, {:journals => :edit}, :require => :loggedin
    map.permission :edit_own_issue_notes, {:journals => :edit}, :require => :loggedin
    map.permission :move_issues, {:issue_moves => [:new, :create]}, :require => :loggedin
    map.permission :delete_issues, {:issues => :destroy}, :require => :member
    # Queries
    map.permission :manage_public_queries, {:queries => [:new, :edit, :destroy]}, :require => :member
    map.permission :save_queries, {:queries => [:new, :edit, :destroy]}, :require => :loggedin
    # Watchers
    map.permission :view_issue_watchers, {}
    map.permission :add_issue_watchers, {:watchers => :new}
    map.permission :delete_issue_watchers, {:watchers => :destroy}
  end

  map.project_module :time_tracking do |map|
    map.permission :log_time, {:timelog => [:new, :create]}, :require => :loggedin
    map.permission :view_time_entries, :timelog => [:index, :show], :time_entry_reports => [:report]
    map.permission :edit_time_entries, {:timelog => [:edit, :update, :destroy]}, :require => :member
    map.permission :edit_own_time_entries, {:timelog => [:edit, :update, :destroy]}, :require => :loggedin
    map.permission :manage_project_activities, {:project_enumerations => [:update, :destroy]}, :require => :member
  end

  map.project_module :news do |map|
    map.permission :manage_news, {:news => [:new, :create, :edit, :update, :destroy], :comments => [:destroy]}, :require => :member
    map.permission :view_news, {:news => [:index, :show]}, :public => true
    map.permission :comment_news, {:comments => :create}
  end

  map.project_module :documents do |map|
    map.permission :manage_documents, {:documents => [:new, :edit, :destroy, :add_attachment]}, :require => :loggedin
    map.permission :view_documents, :documents => [:index, :show, :download]
    map.permission :view_document_watchers, {}
    map.permission :add_document_watchers, {:watchers => :new}
    map.permission :delete_document_watchers, {:watchers => :destroy}
  end

  map.project_module :files do |map|
    map.permission :manage_files, {:files => [:new, :create]}, :require => :loggedin
    map.permission :view_files, :files => :index, :versions => :download
  end

  map.project_module :wiki do |map|
    map.permission :manage_wiki, {:wikis => [:edit, :destroy]}, :require => :member
    map.permission :rename_wiki_pages, {:wiki => :rename}, :require => :member
    map.permission :delete_wiki_pages, {:wiki => :destroy}, :require => :member
    map.permission :view_wiki_pages, :wiki => [:index, :show, :special, :date_index]
    map.permission :export_wiki_pages, :wiki => [:export]
    map.permission :view_wiki_edits, :wiki => [:history, :diff, :annotate]
    map.permission :edit_wiki_pages, :wiki => [:edit, :update, :preview, :add_attachment]
    map.permission :delete_wiki_pages_attachments, {}
    map.permission :protect_wiki_pages, {:wiki => :protect}, :require => :member
    map.permission :view_wiki_page_watchers, {}
    map.permission :add_wiki_page_watchers, {:watchers => :new}
    map.permission :delete_wiki_page_watchers, {:watchers => :destroy}
  end

  map.project_module :repository do |map|
    map.permission :manage_repository, {:repositories => [:edit, :committers, :destroy]}, :require => :member
    map.permission :browse_repository, :repositories => [:show, :browse, :entry, :annotate, :changes, :diff, :stats, :graph]
    map.permission :view_changesets, :repositories => [:show, :revisions, :revision]
    map.permission :commit_access, {}
  end

  map.project_module :boards do |map|
    map.permission :manage_boards, {:boards => [:new, :edit, :destroy]}, :require => :member
    map.permission :view_messages, {:boards => [:index, :show], :messages => [:show]}, :public => true
    map.permission :add_messages, {:messages => [:new, :reply, :quote]}
    map.permission :edit_messages, {:messages => :edit}, :require => :member
    map.permission :edit_own_messages, {:messages => :edit}, :require => :loggedin
    map.permission :delete_messages, {:messages => :destroy}, :require => :member
    map.permission :delete_own_messages, {:messages => :destroy}, :require => :loggedin
    map.permission :view_board_watchers, {}
    map.permission :add_board_watchers, {:watchers => :new}
    map.permission :delete_board_watchers, {:watchers => :destroy}

    map.permission :view_message_watchers, {}
    map.permission :add_message_watchers, {:watchers => :new}
    map.permission :delete_message_watchers, {:watchers => :destroy}

  end

  map.project_module :calendar do |map|
    map.permission :view_calendar, :calendars => [:show, :update]
  end

  map.project_module :gantt do |map|
    map.permission :view_gantt, :gantts => [:show, :update]
  end
end

Redmine::MenuManager.map :top_menu do |menu|
  menu.push :home, :home_path
  menu.push :my_page, { :controller => 'my', :action => 'page' }, :if => Proc.new { User.current.logged? }
  menu.push :projects, { :controller => 'projects', :action => 'index' }, :caption => :label_project_plural
  menu.push :administration, { :controller => 'admin', :action => 'index' }, :if => Proc.new { User.current.admin? }, :last => true
  menu.push :help, Redmine::Info.help_url, :last => true, :caption => "?"
end

Redmine::MenuManager.map :account_menu do |menu|
  menu.push :my_account, { :controller => 'my', :action => 'account' }, :if => Proc.new { User.current.logged? }
  menu.push :logout, :signout_path, :if => Proc.new { User.current.logged? }
end

Redmine::MenuManager.map :application_menu do |menu|
  # Empty
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :projects, {:controller => 'admin', :action => 'projects'}, :caption => :label_project_plural
  menu.push :users, {:controller => 'users'}, :caption => :label_user_plural
  menu.push :groups, {:controller => 'groups'}, :caption => :label_group_plural
  menu.push :roles, {:controller => 'roles'}, :caption => :label_role_and_permissions
  menu.push :trackers, {:controller => 'trackers'}, :caption => :label_tracker_plural
  menu.push :issue_statuses, {:controller => 'issue_statuses'}, :caption => :label_issue_status_plural,
            :html => {:class => 'issue_statuses'}
  menu.push :workflows, {:controller => 'workflows', :action => 'edit'}, :caption => :label_workflow
  menu.push :custom_fields, {:controller => 'custom_fields'},  :caption => :label_custom_field_plural,
            :html => {:class => 'custom_fields'}
  menu.push :enumerations, {:controller => 'enumerations'}
  menu.push :settings, {:controller => 'settings'}
  menu.push :ldap_authentication, {:controller => 'ldap_auth_sources', :action => 'index'},
            :html => {:class => 'server_authentication'}
  menu.push :plugins, {:controller => 'admin', :action => 'plugins'}, :last => true
  menu.push :info, {:controller => 'admin', :action => 'info'}, :caption => :label_information_plural, :last => true
end

Redmine::MenuManager.map :project_menu do |menu|
  include ProjectsHelper

  # TODO: refactor to a helper that is available before app/helpers along with the other procs.
  issue_query_proc = Proc.new { |p|
    ##### Taken from IssuesHelper
    # User can see public queries and his own queries
    visible = ARCondition.new(["is_public = ? OR user_id = ?", true, (User.current.logged? ? User.current.id : 0)])
    # Project specific queries and global queries
    visible << (p.nil? ? ["project_id IS NULL"] : ["project_id IS NULL OR project_id = ?", p.id])
    sidebar_queries = Query.find(:all,
                                 :select => 'id, name',
                                 :order => "name ASC",
                                 :conditions => visible.conditions)

    sidebar_queries.collect do |query|
      Redmine::MenuManager::MenuItem.new("query-#{query.id}".to_sym, { :controller => 'issues', :action => 'index', :project_id => p, :query_id => query }, {
                                           :caption => query.name,
                                           :param => :project_id,
                                           :parent => :issues
                                         })
    end
  }

  menu.push(:overview, { :controller => 'projects', :action => 'show' })
  menu.push(:activity, { :controller => 'activities', :action => 'index' })
  menu.push(:roadmap, { :controller => 'versions', :action => 'index' }, {
              :param => :project_id,
              :if => Proc.new { |p| p.shared_versions.any? },
              :children => Proc.new { |p|
                versions = p.shared_versions.sort
                versions.reject! {|version| version.closed? || version.completed? }

                versions.collect do |version|
                  Redmine::MenuManager::MenuItem.new("version-#{version.id}".to_sym,
                                                     { :controller => 'versions', :action => 'show', :id => version },
                                                     {
                                                       :caption => version.name,
                                                       :parent => :roadmap
                                                     })
                end
              }
            })
  menu.push(:issues, { :controller => 'issues', :action => 'index' }, {
              :param => :project_id,
              :caption => :label_issue_plural,
              :children => issue_query_proc
            })
  menu.push(:new_issue, { :controller => 'issues', :action => 'new', :copy_from => nil }, {
              :param => :project_id,
              :caption => :label_issue_new,
              :parent => :issues,
              :html => { :accesskey => Redmine::AccessKeys.key_for(:new_issue) }
            })
  menu.push(:all_open_issues, { :controller => 'issues', :action => 'index', :set_filter => 1 }, {
              :param => :project_id,
              :caption => :field_issue_view_all_open,
              :parent => :issues
            })
  menu.push(:new_query, { :controller => 'queries', :action => 'new'}, {
              :param => :project_id,
              :caption => :field_new_saved_query,
              :parent => :issues
            })
  menu.push(:issue_summary, { :controller => 'reports', :action => 'issue_report' }, {
              :caption => :field_issue_summary,
              :parent => :issues
            })
  menu.push(:time_entries, { :controller => 'timelog', :action => 'index' }, {
              :param => :project_id,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) }
            });
  menu.push(:new_time_entry, { :controller => 'timelog', :action => 'new' }, {
              :param => :project_id,
              :if => Proc.new {|p| User.current.allowed_to?(:log_time, p) },
              :parent => :time_entries
            })
  menu.push(:time_entry_report, { :controller => 'time_entry_reports', :action => 'report' }, {
              :param => :project_id,
              :if => Proc.new {|p| User.current.allowed_to?(:view_time_entries, p) },
              :parent => :time_entries
            })
  menu.push(:gantt, { :controller => 'gantts', :action => 'show' }, {
              :param => :project_id,
              :caption => :label_gantt
            })
  menu.push(:calendar, { :controller => 'calendars', :action => 'show' }, {
              :param => :project_id,
              :caption => :label_calendar
            })
  menu.push(:news, { :controller => 'news', :action => 'index' }, {
              :param => :project_id,
              :caption => :label_news_plural
            })
  menu.push(:new_news, {:controller => 'news', :action => 'new' }, {
              :param => :project_id,
              :caption => :label_news_new,
              :parent => :news,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_news, p) }
            })
  menu.push(:documents, { :controller => 'documents', :action => 'index' }, {
              :param => :project_id,
              :caption => :label_document_plural
            })
  menu.push(:new_document, { :controller => 'documents', :action => 'new' }, {
              :param => :project_id,
              :caption => :label_document_new,
              :parent => :documents,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_documents, p) }
            })
  menu.push(:wiki, { :controller => 'wiki', :action => 'show', :id => nil }, {
              :param => :project_id,
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
            })
  menu.push(:wiki_by_title, { :controller => 'wiki', :action => 'index' }, {
              :caption => :label_index_by_title,
              :parent => :wiki,
              :param => :project_id,
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
            })
  menu.push(:wiki_by_date, { :controller => 'wiki', :action => 'date_index'}, {
              :caption => :label_index_by_date,
              :parent => :wiki,
              :param => :project_id,
              :if => Proc.new { |p| p.wiki && !p.wiki.new_record? }
            })
  menu.push(:boards, { :controller => 'boards', :action => 'index', :id => nil }, {
              :param => :project_id,
              :caption => :label_board_plural,
              :if => Proc.new { |p| p.boards.any? },
              :children => Proc.new {|project|
                project.boards.collect do |board|
                  Redmine::MenuManager::MenuItem.new(
                                                     "board-#{board.id}".to_sym,
                                                     { :controller => 'boards', :action => 'show', :project_id => project, :id => board },
                                                     {
                                                       :caption => board.name # is h() in menu_helper.rb
                                                     })
                end
              }
            })
  menu.push(:new_board, { :controller => 'boards', :action => 'new' }, {
              :caption => :label_board_new,
              :param => :project_id,
              :parent => :boards,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_boards, p) }
            })
  menu.push(:files, { :controller => 'files', :action => 'index' }, {
              :caption => :label_file_plural,
              :param => :project_id
            })
  menu.push(:new_file, { :controller => 'files', :action => 'new' }, {
              :caption => :label_attachment_new,
              :param => :project_id,
              :parent => :files,
              :if => Proc.new {|p| User.current.allowed_to?(:manage_files, p) }
            })
  menu.push(:repository, { :controller => 'repositories', :action => 'show' }, {
              :if => Proc.new { |p| p.repository && !p.repository.new_record? }
            })
  menu.push(:settings, { :controller => 'projects', :action => 'settings' }, {
              :last => true,
              :children => Proc.new { |p|
                @project = p # @project used in the helper
                project_settings_tabs.collect do |tab|
                  Redmine::MenuManager::MenuItem.new("settings-#{tab[:name]}".to_sym,
                                                     { :controller => 'projects', :action => 'settings', :id => p, :tab => tab[:name] },
                                                     {
                                                       :caption => tab[:label]
                                                     })
                end
              }
            })
end

Redmine::Activity.map do |activity|
  activity.register :issues, :class_name => 'Issue'
  activity.register :changesets
  activity.register :news
  activity.register :documents, :class_name => %w(Document Attachment)
  activity.register :files, :class_name => 'Attachment'
  activity.register :wiki_edits, :class_name => 'WikiContent', :default => false
  activity.register :messages, :default => false
  activity.register :time_entries, :default => false
end

Redmine::Search.map do |search|
  search.register :issues
  search.register :news
  search.register :documents
  search.register :changesets
  search.register :wiki_pages
  search.register :messages
  search.register :projects
end

Redmine::WikiFormatting.map do |format|
  format.register :textile, Redmine::WikiFormatting::Textile::Formatter, Redmine::WikiFormatting::Textile::Helper
end

ActionView::Template.register_template_handler :rsb, Redmine::Views::ApiTemplateHandler
