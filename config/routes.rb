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

  match 'help/wiki_syntax', :to => 'help#wiki_syntax', :via => [:get]
  match 'help/wiki_syntax_detailed', :to => 'help#wiki_syntax_detailed', :via => [:get]

  map.connect 'projects/:id/wiki', :controller => 'wikis', :action => 'edit', :conditions => {:method => :post}
  map.connect 'projects/:id/wiki/destroy', :controller => 'wikis', :action => 'destroy', :conditions => {:method => [:get, :post]}

  match 'boards/:board_id/topics/new', :to => 'messages#new', :via => [:get, :post], :as => 'new_board_message'
  get 'boards/:board_id/topics/:id', :to => 'messages#show', :as => 'board_message'
  match 'boards/:board_id/topics/quote/:id', :to => 'messages#quote', :via => [:get, :post]
  get 'boards/:board_id/topics/:id/edit', :to => 'messages#edit'

  post 'boards/:board_id/topics/preview', :to => 'messages#preview', :as => 'preview_board_message'
  post 'boards/:board_id/topics/:id/replies', :to => 'messages#reply'
  post 'boards/:board_id/topics/:id/edit', :to => 'messages#edit'
  post 'boards/:board_id/topics/:id/destroy', :to => 'messages#destroy'

  resources :issue_moves, :only => [:new, :create], :path => "/issues/move"

  # Misc issue routes. TODO: move into resources
  match '/issues/auto_complete', :to => 'auto_completes#issues', :via => :get, :as => 'auto_complete_issues'
  match '/users/auto_complete', :to => 'auto_completes#users', :via => :get, :as => 'auto_complete_users'
  match '/projects/auto_complete', :to => 'auto_completes#projects', :via => :post, :as => 'auto_complete_projects'

  # TODO: would look nicer as /issues/:id/preview
  match '/issues/preview/new/:project_id', :to => 'previews#issue', :as => 'preview_new_issue'
  match '/issues/preview/edit/:id', :to => 'previews#issue', :as => 'preview_edit_issue'

  match '/issues/context_menu', :to => 'context_menus#issues', :as => 'issues_context_menu'
  match '/issues/changes', :to => 'journals#index', :as => 'issue_changes'
  match '/issues/:id/quoted', :to => 'journals#new', :id => /\d+/, :via => :post, :as => 'quoted_issue'
  match '/journals/:id/diff/:field', :to => 'journals#diff', :id => /\d+/, :via => :get, :as => 'journal_diff'
  match '/journals/edit/:id', :to => 'journals#edit', :id => /\d+/, :via => [:get, :post]

  map.with_options :controller => 'gantts', :action => 'show' do |gantts_routes|
    gantts_routes.connect '/projects/:project_id/issues/gantt'
    gantts_routes.connect '/projects/:project_id/issues/gantt.:format'
    gantts_routes.connect '/issues/gantt.:format'
  end

  map.with_options :controller => 'calendars', :action => 'show' do |calendars_routes|
    calendars_routes.connect '/projects/:project_id/issues/calendar'
    calendars_routes.connect '/issues/calendar'
  end

  map.with_options :controller => 'reports', :conditions => {:method => :get} do |reports|
    reports.connect 'projects/:id/issues/report', :action => 'issue_report'
    reports.connect 'projects/:id/issues/report/:detail', :action => 'issue_report_details'
  end

  match 'my/account', :controller => 'my', :action => 'account', :via => [:get, :post]
  match 'my/account/destroy', :controller => 'my', :action => 'destroy', :via => [:get, :post]
  match 'my/page', :controller => 'my', :action => 'page', :via => :get
  match 'my', :controller => 'my', :action => 'index', :via => :get # Redirects to my/page
  match 'my/reset_rss_key', :controller => 'my', :action => 'reset_rss_key', :via => :post
  match 'my/reset_api_key', :controller => 'my', :action => 'reset_api_key', :via => :post
  match 'my/password', :controller => 'my', :action => 'password', :via => [:get, :post]
  match 'my/page_layout', :controller => 'my', :action => 'page_layout', :via => :get
  match 'my/add_block', :controller => 'my', :action => 'add_block', :via => :post
  match 'my/remove_block', :controller => 'my', :action => 'remove_block', :via => :post
  match 'my/order_blocks', :controller => 'my', :action => 'order_blocks', :via => :post

  map.with_options :controller => 'users' do |users|
    users.user_membership 'users/:id/memberships/:membership_id', :action => 'edit_membership', :conditions => {:method => :put}
    users.connect 'users/:id/memberships/:membership_id', :action => 'destroy_membership', :conditions => {:method => :delete}
    users.user_memberships 'users/:id/memberships', :action => 'edit_membership', :conditions => {:method => :post}
  end
  map.resources :users

  # For nice "roadmap" in the url for the index action
  map.connect 'projects/:project_id/roadmap', :controller => 'versions', :action => 'index'

  match '/news/preview', :controller => 'previews', :action => 'news', :as => 'preview_news'
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
    project.resources :queries, :only => [:new, :create]
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

  map.resources :time_entries, :controller => 'timelog', :collection => {:report => :get}

  get 'projects/:id/activity', :to => 'activities#index'
  get 'projects/:id/activity.:format', :to => 'activities#index'
  get 'activity', :to => 'activities#index'

  scope :controller => 'repositories' do
    scope :via => :get do
      match '/projects/:id/repository', :action => :show, :path => nil, :rev => nil
      match '/projects/:id/repository/statistics', :action => :stats
      match '/projects/:id/repository/committers', :action => :committers
      match '/projects/:id/repository/graph', :action => :graph
      match '/projects/:id/repository/revisions/:rev', :action => :revision, :rev => /[a-z0-9\.\-_]+/
      match '/projects/:id/repository/revisions', :action => :revisions
      match '/projects/:id/repository/revision', :action => :revision
      match '/projects/:id/repository/revisions/:rev/:format(/*path(.:ext))', :action => :entry, :format => /raw/, :rev => /[a-z0-9\.\-_]+/
      match '/projects/:id/repository/revisions/:rev/:action(/*path(.:ext))', :rev => /[a-z0-9\.\-_]+/, :action => /(browse|show|entry|changes|annotate|diff)/
      match '/projects/:id/repository/:format(/*path(.:ext))', :action => :entry, :format => /raw/
      match '/projects/:id/repository/:action(/*path(.:ext))', :action => /(browse|show|entry|changes|annotate|diff)/
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
