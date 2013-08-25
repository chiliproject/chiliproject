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

Redmine::Application.routes.draw do |map|
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.

  # Here's a sample route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  map.home '', :controller => 'welcome', :conditions => {:method => :get}

  match 'login', :to => 'account#login', :as => 'signin', :via => [:get, :post]
  match 'logout', :to => 'account#logout', :as => 'signout', :via => [:get, :post]
  match 'account/register', :to => 'account#register', :via => [:get, :post], :as => 'register'
  match 'account/lost_password', :to => 'account#lost_password', :via => [:get, :post], :as => 'lost_password'
  match 'account/login', :to => 'account#login', :via => [:get, :post]
  match 'account/logout', :to => 'account#logout', :via => [:get, :post]
  match 'account/activate', :to => 'account#activate', :via => :get

  map.connect 'help/wiki_syntax', :controller => 'help', :action => 'wiki_syntax', :conditions => {:method => :get}
  map.connect 'help/wiki_syntax_detailed', :controller => 'help', :action => 'wiki_syntax_detailed', :conditions => {:method => :get}

  map.connect '/time_entries/destroy',
                   :controller => 'timelog', :action => 'destroy', :conditions => { :method => :delete }

  map.resources :time_entries, :controller => 'timelog', :collection => {:report => :get}

  map.connect 'projects/:id/wiki', :controller => 'wikis', :action => 'edit', :conditions => {:method => :post}
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => [:get, :post]}

  map.with_options :controller => 'messages' do |messages_routes|
    messages_routes.with_options :conditions => {:method => :get} do |messages_views|
      messages_views.connect 'boards/:board_id/topics/new', :action => 'new'
      messages_views.connect 'boards/:board_id/topics/:id', :action => 'show'
      messages_views.connect 'boards/:board_id/topics/:id/edit', :action => 'edit'
    end
    messages_routes.with_options :conditions => {:method => :post} do |messages_actions|
      messages_actions.connect 'boards/:board_id/topics/new', :action => 'new'
      messages_actions.connect 'boards/:board_id/topics/preview', :action => 'preview'
      messages_actions.connect 'boards/:board_id/topics/quote/:id', :action => 'quote'
      messages_actions.connect 'boards/:board_id/topics/:id/replies', :action => 'reply'
      messages_actions.connect 'boards/:board_id/topics/:id/edit', :action => 'edit'
      messages_actions.connect 'boards/:board_id/topics/:id/destroy', :action => 'destroy'
    end
  end

  map.resources :issue_moves, :only => [:new, :create], :path_prefix => '/issues', :as => 'move'

  # Misc issue routes. TODO: move into resources
  map.auto_complete_issues '/issues/auto_complete', :controller => 'auto_completes', :action => 'issues', :conditions => { :method => :get }
  map.auto_complete_users '/users/auto_complete', :controller => 'auto_completes', :action => 'users', :conditions => { :method => :get }
  map.auto_complete_projects '/projects/auto_complete', :controller => 'auto_completes', :action => 'projects', :conditions => { :method => :post }

  # TODO: would look nicer as /issues/:id/preview
  map.preview_new_issue '/issues/preview/new/:project_id', :controller => 'previews',
                        :action => 'issue'
  map.preview_edit_issue '/issues/preview/edit/:id', :controller => 'previews',
                         :action => 'issue'

  map.issues_context_menu '/issues/context_menu', :controller => 'context_menus', :action => 'issues'
  map.issue_changes '/issues/changes', :controller => 'journals', :action => 'index'
  map.quoted_issue '/issues/:id/quoted', :controller => 'journals', :action => 'new', :id => /\d+/, :conditions => { :method => :post }
  map.journal_diff '/journals/:id/diff/:field', :controller => 'journals', :action => 'diff', :conditions => { :method => :get }
  map.connect '/journals/edit/:id', :controller => 'journals', :action => 'edit', :id => /\d+/, :conditions => { :method => [:get, :post] }

  map.with_options :controller => 'gantts', :action => 'show' do |gantts_routes|
    gantts_routes.connect '/projects/:project_id/issues/gantt'
    gantts_routes.connect '/issues/gantt'
  end

  map.with_options :controller => 'calendars', :action => 'show' do |calendars_routes|
    calendars_routes.connect '/projects/:project_id/issues/calendar'
    calendars_routes.connect '/issues/calendar'
  end

  map.with_options :controller => 'reports', :conditions => {:method => :get} do |reports|
    reports.connect 'projects/:id/issues/report', :action => 'issue_report'
    reports.connect 'projects/:id/issues/report/:detail', :action => 'issue_report_details'
  end

  map.connect 'my/account', :controller => 'my', :action => 'account', :conditions => {:method => [:get, :post]}
  map.connect 'my/page', :controller => 'my', :action => 'page', :conditions => {:method => :get}
  map.connect 'my', :controller => 'my', :action => 'index', :conditions => {:method => :get} # Redirects to my/page
  map.connect 'my/reset_rss_key', :controller => 'my', :action => 'reset_rss_key', :conditions => {:method => :post}
  map.connect 'my/reset_api_key', :controller => 'my', :action => 'reset_api_key', :conditions => {:method => :post}
  map.connect 'my/password', :controller => 'my', :action => 'password', :conditions => {:method => [:get, :post]}
  map.connect 'my/page_layout', :controller => 'my', :action => 'page_layout', :conditions => {:method => :get}
  map.connect 'my/add_block', :controller => 'my', :action => 'add_block', :conditions => {:method => :post}
  map.connect 'my/remove_block', :controller => 'my', :action => 'remove_block', :conditions => {:method => :post}
  map.connect 'my/order_blocks', :controller => 'my', :action => 'order_blocks', :conditions => {:method => :post}

  map.with_options :controller => 'users' do |users|
    users.user_membership 'users/:id/memberships/:membership_id', :action => 'edit_membership', :conditions => {:method => :put}
    users.connect 'users/:id/memberships/:membership_id', :action => 'destroy_membership', :conditions => {:method => :delete}
    users.user_memberships 'users/:id/memberships', :action => 'edit_membership', :conditions => {:method => :post}
  end
  map.resources :users

  # For nice "roadmap" in the url for the index action
  map.connect 'projects/:project_id/roadmap', :controller => 'versions', :action => 'index'

  map.preview_news '/news/preview', :controller => 'previews', :action => 'news'
  map.connect 'news/:id/comments', :controller => 'comments', :action => 'create', :conditions => {:method => :post}
  map.connect 'news/:id/comments/:comment_id', :controller => 'comments', :action => 'destroy', :conditions => {:method => :delete}

  map.connect 'watchers/new', :controller=> 'watchers', :action => 'new', :conditions => {:method => [:get, :post]}
  map.connect 'watchers/destroy', :controller=> 'watchers', :action => 'destroy', :conditions => {:method => :post}
  map.connect 'watchers/watch', :controller=> 'watchers', :action => 'watch', :conditions => {:method => :post}
  map.connect 'watchers/unwatch', :controller=> 'watchers', :action => 'unwatch', :conditions => {:method => :post}

  # TODO: port to be part of the resources route(s)
  map.with_options :conditions => {:method => :get} do |project_views|
    project_views.connect 'projects/:id/settings/:tab',
                          :controller => 'projects', :action => 'settings'
    project_views.connect 'projects/:project_id/issues/:copy_from/copy',
                          :controller => 'issues', :action => 'new'
  end

  map.resources :projects, :member => {
    :copy => [:get, :post],
    :settings => :get,
    :modules => :post,
    :archive => :post,
    :unarchive => :post
  } do |project|
    project.resource :enumerations, :controller => 'project_enumerations',
                     :only => [:update, :destroy]
    # issue form update
    project.issue_form 'issues/new', :controller => 'issues',
                       :action => 'new', :conditions => {:method => [:post, :put]}
    project.resources :issues, :only => [:index, :new, :create] do |issues|
      issues.resources :time_entries, :controller => 'timelog', :collection => {:report => :get}
    end

    project.resources :files, :only => [:index, :new, :create]
    project.resources :versions, :shallow => true, :collection => {:close_completed => :put}, :member => {:status_by => :post}
    project.resources :news, :shallow => true
    project.resources :time_entries, :controller => 'timelog',
                      :collection => {:report => :get}
    project.resources :boards
    project.resources :documents, :shallow => true, :member => {:add_attachment => :post}
    project.resources :issue_categories, :shallow => true
    project.resources :queries, :except => [:show]
    project.resources :repositories, :shallow => true, :except => [:index, :show],
                      :member => {:committers => [:get, :post]}
    project.resources :memberships, :shallow => true, :controller => 'members',
                      :only => [:create, :update, :destroy],
                      :collection => {:autocomplete => :get}

    project.wiki_start_page 'wiki', :controller => 'wiki', :action => 'show', :conditions => {:method => :get}
    project.wiki_index 'wiki/index', :controller => 'wiki', :action => 'index', :conditions => {:method => :get}
    project.wiki_diff 'wiki/:id/diff/:version', :controller => 'wiki', :action => 'diff', :version => nil
    project.wiki_diff 'wiki/:id/diff/:version/vs/:version_from', :controller => 'wiki', :action => 'diff'
    project.wiki_annotate 'wiki/:id/annotate/:version', :controller => 'wiki', :action => 'annotate'
    project.resources :wiki, :except => [:new, :create], :member => {
      :rename => [:get, :post],
      :history => :get,
      :preview => :any,
      :protect => :post,
      :add_attachment => :post
    }, :collection => {
      :export => :get,
      :date_index => :get
    }
  end

  map.connect 'news', :controller => 'news', :action => 'index'
  map.connect 'news.:format', :controller => 'news', :action => 'index'

  map.resources :queries, :except => [:show]

  map.resources :issues, :member => { :edit => :post },
                :collection => {:bulk_edit => :get, :bulk_update => :post} do |issues|
    issues.resources :relations, :controller => 'issue_relations', :only => [:show, :create, :destroy]
    issues.resources :time_entries, :controller => 'timelog', :collection => {:report => :get}
  end

  # Bulk deletion
  map.connect '/issues', :controller => 'issues', :action => 'destroy',
              :conditions => {:method => :delete}

  map.with_options :controller => 'activities', :action => 'index', :conditions => {:method => :get} do |activity|
    activity.connect 'projects/:id/activity'
    activity.connect 'projects/:id/activity.:format'
    activity.connect 'activity', :id => nil
    activity.connect 'activity.:format', :id => nil
  end

  map.with_options :controller => 'repositories' do |repositories|
    repositories.with_options :conditions => {:method => :get} do |repository_views|
      repository_views.connect 'projects/:id/repository', :action => 'show'
      repository_views.connect 'projects/:id/repository/statistics', :action => 'stats'
      repository_views.connect 'projects/:id/repository/revisions', :action => 'revisions'
      repository_views.connect 'projects/:id/repository/revisions.:format', :action => 'revisions'
      repository_views.connect 'projects/:id/repository/revisions/:rev', :action => 'revision'
      repository_views.connect 'projects/:id/repository/revisions/:rev/diff', :action => 'diff'
      repository_views.connect 'projects/:id/repository/revisions/:rev/diff.:format', :action => 'diff'
      repository_views.connect 'projects/:id/repository/revisions/:rev/raw/*path', :action => 'entry', :format => 'raw', :requirements => { :rev => /[a-z0-9\.\-_]+/ }
      repository_views.connect 'projects/:id/repository/revisions/:rev/:action/*path', :requirements => { :rev => /[a-z0-9\.\-_]+/ }
      repository_views.connect 'projects/:id/repository/raw/*path', :action => 'entry', :format => 'raw'
      repository_views.connect 'projects/:id/repository/browse/*path', :action => 'browse'
      repository_views.connect 'projects/:id/repository/entry/*path', :action => 'entry'
      repository_views.connect 'projects/:id/repository/changes/*path', :action => 'changes'
      repository_views.connect 'projects/:id/repository/annotate/*path', :action => 'annotate'
      repository_views.connect 'projects/:id/repository/diff/*path', :action => 'diff'
      repository_views.connect 'projects/:id/repository/show/*path', :action => 'show'
      repository_views.connect 'projects/:id/repository/graph', :action => 'graph'
      repository_views.connect 'projects/:id/repository/revision', :action => 'revision'
    end
  end

  # additional routes for having the file name at the end of url
  map.connect 'attachments/:id/:filename', :controller => 'attachments', :action => 'show', :id => /\d+/, :filename => /.*/, :conditions => {:method => :get}
  map.connect 'attachments/download/:id/:filename', :controller => 'attachments', :action => 'download', :id => /\d+/, :filename => /.*/, :conditions => {:method => :get}
  map.connect 'attachments/download/:id', :controller => 'attachments', :action => 'download', :id => /\d+/, :conditions => {:method => :get}
  map.resources :attachments, :only => [:show, :destroy]

  map.resources :groups
  map.group_users 'groups/:id/users', :controller => 'groups', :action => 'add_users', :id => /\d+/, :conditions => {:method => :post}
  map.group_user  'groups/:id/users/:user_id', :controller => 'groups', :action => 'remove_user', :id => /\d+/, :conditions => {:method => :delete}
  map.connect 'groups/destroy_membership/:id', :controller => 'groups', :action => 'destroy_membership', :id => /\d+/, :conditions => {:method => :post}
  map.connect 'groups/edit_membership/:id', :controller => 'groups', :action => 'edit_membership', :id => /\d+/, :conditions => {:method => :post}

  map.resources :trackers, :except => :show
  map.resources :issue_statuses, :except => :show, :collection => {:update_issue_done_ratio => :post}
  map.resources :custom_fields, :except => :show
  map.resources :roles, :except => :show, :collection => {:permissions => [:get, :post]}
  map.resources :enumerations, :except => :show

  map.connect 'journals/diff/:id', :controller => 'journals', :action => 'diff'

  map.connect 'projects/:id/search', :controller => 'search', :action => 'index', :conditions => {:method => :get}
  map.connect 'search', :controller => 'search', :action => 'index', :conditions => {:method => :get}

  map.connect 'mail_handler', :controller => 'mail_handler', :action => 'index', :conditions => {:method => :post}

  map.connect 'admin', :controller => 'admin', :action => 'index', :conditions => {:method => :get}
  map.connect 'admin/projects', :controller => 'admin', :action => 'projects', :conditions => {:method => :get}
  map.connect 'admin/plugins', :controller => 'admin', :action => 'plugins', :conditions => {:method => :get}
  map.connect 'admin/info', :controller => 'admin', :action => 'info', :conditions => {:method => :get}
  map.connect 'admin/test_email', :controller => 'admin', :action => 'test_email', :conditions => {:method => :get}
  map.connect 'admin/default_configuration', :controller => 'admin', :action => 'default_configuration', :conditions => {:method => :post}

  map.resources :auth_sources, :member => {:test_connection => :get}

  map.connect 'workflows', :controller => 'workflows', :action => 'index', :conditions => {:method => :get}
  map.connect 'workflows/edit', :controller => 'workflows', :action => 'edit', :conditions => {:method => [:get, :post]}
  map.connect 'workflows/copy', :controller => 'workflows', :action => 'copy', :conditions => {:method => [:get, :post]}
  map.connect 'settings', :controller => 'settings', :action => 'index', :conditions => {:method => :get}
  map.connect 'settings/edit', :controller => 'settings', :action => 'edit', :conditions => {:method => [:get, :post]}
  map.connect 'settings/plugin/:id', :controller => 'settings', :action => 'plugin', :conditions => {:method => [:get, :post]}

  map.with_options :controller => 'sys' do |sys|
    sys.connect 'sys/projects.:format', :action => 'projects', :conditions => {:method => :get}
    sys.connect 'sys/projects/:id/repository.:format', :action => 'create_project_repository', :conditions => {:method => :post}
    sys.connect 'sys/fetch_changesets', :action => 'fetch_changesets', :conditions => {:method => :get}
  end

  map.connect 'robots.txt', :controller => 'welcome', :action => 'robots', :conditions => {:method => :get}

  # Used for OpenID
  map.root :controller => 'account', :action => 'login'
end
