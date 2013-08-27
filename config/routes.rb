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

Redmine::Application.routes.draw do
  # Add your own custom routes here.
  # The priority is based upon order of creation: first created -> highest priority.
  root :to => 'welcome#index', :as => 'home'
  get 'robots.txt' => 'welcome#robots'

  match 'login', :to => 'account#login', :as => 'signin', :via => [:get, :post]
  match 'logout', :to => 'account#logout', :as => 'signout', :via => [:get, :post]
  match 'account/register', :to => 'account#register', :via => [:get, :post], :as => 'register'
  match 'account/lost_password', :to => 'account#lost_password', :via => [:get, :post], :as => 'lost_password'
  match 'account/login', :to => 'account#login', :via => [:get, :post]
  match 'account/logout', :to => 'account#logout', :via => [:get, :post]
  match 'account/activate', :to => 'account#activate', :via => :get

  match 'help/wiki_syntax', :to => 'help#wiki_syntax', :via => [:get]
  match 'help/wiki_syntax_detailed', :to => 'help#wiki_syntax_detailed', :via => [:get]

  match 'time_entries/destroy',
        :to => 'timelog#destroy', :via => [:delete]

  # <by Chili>
  resource :account, :controller => 'account', :only => [] do
    match 'register', :via => [:get, :post]
    match 'lost_password', :via => [:get, :post]
    get 'activate'
  end
  # </by Chili>

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

  match '/projects/:project_id/issues/gantt', :to => 'gantts#show'
  match '/issues/gantt', :to => 'gantts#show'

  match '/projects/:project_id/issues/calendar', :to => 'calendars#show'
  match '/issues/calendar', :to => 'calendars#show'

  resources :roles, :only => [:index, :new, :edit, :destroy] do
    collection do
      get 'report'
    end
  end

  resources :trackers, :only => [:index, :new, :edit, :destroy]

  resources :workflows, :only => [:index] do
    collection do
      match 'edit', :via => [:get, :post]
      match 'copy', :via => [:get, :post]
    end
  end

  resources :custom_fields, :only => [:index, :destroy] do
    collection do
      match 'new', :via => [:get, :post]
      match 'edit', :via => [:get, :post]
    end
  end

  resources :enumerations, :only => [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get 'list'
    end
  end

  resources :settings, :only => [:index] do
    collection do
      match 'edit', :via => [:get, :post]
      match 'plugin', :via => [:get, :post]
    end
  end

  resources :ldap_auth_sources, :only => [:index, :new, :create, :edit, :update, :destroy] do
    get 'test_connection'
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

  resources :issue_statuses, :only => [:index, :new, :edit, :update, :destroy] do
    collection do
      post 'update_issue_done_ratio'
    end
  end

  get 'admin' => 'admin#index'
  resource :admin, :controller => 'admin', :only => [] do
    get 'projects'
    get 'plugins'
    get 'info'
  end

  resources :projects do
    get 'activity' => 'activities#index' # CHANGED :id is not :project_id
    post 'archive' # should be PUT?
    get 'copy'
    post 'copy'
    get '/destroy' => 'projects#destroy', :as => 'destroy'
    put 'modules'
    get 'roadmap' => 'versions#index'
    get 'search' => 'search#index'
    get 'settings(/:tab)' => 'projects#settings', :as => 'settings'
    post 'unarchive' # should be PUT?

    resources :boards

    # TODO: What do we need the update for?
    # CHANGED: moved out of /issues
    resource :calendar, :only => [:show, :update]

    resources :documents, :only => [:index, :new, :create]

    resource :enumerations, :controller => 'project_enumerations', :only => [:update, :destroy]

    resources :files, :only => [:index, :new, :create]

    # TODO: What do we need the update for?
    # CHANGED: moved out of /issues
    resource :gantt, :only => [:show, :update]

    resources :issue_categories, :except => [:index, :show]

    resources :issues, :only => [:new, :create, :index] do
      collection do
        get 'report' => 'reports#issue_report'
        get 'report/:detail' => 'reports#issue_report_details'
      end
    end

    resources :issues, :only => [] do
      # copy needs to be declared after new as long as both point to issues#new
      get 'copy' => 'issues#new'
    end
    # CHANGED: Members are only managed through the members controller
    # The membership methods on UserController should be removed
    resources :members, :except => :show

    resources :news, :only => [:new, :create]

    resources :queries, :only => [:new, :create]
    resources 'time_entries', :controller => 'timelog', :only => [:index, :new, :create] do
      get 'report' => 'time_entry_reports#report', :on => :collection
    end
  end

  resources :queries, :except => [:show]

  resources :news, :only => [:index, :show, :edit, :update, :destroy]
  match '/news/:id/comments', :to => 'comments#create', :via => :post
  match '/news/:id/comments/:comment_id', :to => 'comments#destroy', :via => :delete

  resources :issues do
    member do
      post 'edit'
    end
    collection do
      get 'bulk_edit'
      post 'bulk_update'
    end
    resources :time_entries, :controller => 'timelog' do
      collection do
        get 'report'
      end
    end
    resources :relations, :controller => 'issue_relations', :only => [:show, :create, :destroy]
  end


  resources :time_entries, :controller => 'timelog' do
    collection do
      get 'report'
    end
    resources :versions do
      collection do
        put 'close_completed'
      end
      post 'status_by', :on => :member
    end

    # TODO: Adapt the actions in the WikisController
    resources :wiki, :shallow => true
    resources :wiki, :only => [] do
      collection do
        get 'index' => 'wiki#show', :as => 'start_page'

        get '/index' => 'wiki#index'
        get 'date_index' => 'wiki#date_index'

        put 'update' => 'wikis#update'
        get 'export' => 'wiki#export'

        # To display the confirmation
        # TODO: Is this RESTful?
        match '/destroy' => 'wikis#destroy', :via => [:get, :post], :as => 'destroy'
      end

      member do
        post 'add_attachment'
        get 'annotate/:version' => 'wiki#annotate', :as => 'annotate'

        get 'diff/:version(/vs/:version_from)' => 'wiki#diff', :as => 'diff'
        get 'history'
        post 'preview'
        post 'protect'
        get 'rename' # TODO: this should not be needed, put this into edit
        post 'rename'
      end
    end
  end

  get 'projects/:id/activity', :to => 'activities#index'
  get 'projects/:id/activity.:format', :to => 'activities#index'
  get 'activity', :to => 'activities#index'

  get 'attachments/:id(/:filename)' => 'attachments#show', :id => /\d+/, :as => 'attachment'
  get 'attachments/download/:id(/:filename)' => 'attachments#download', :id => /\d+/, :as => 'download_attachment'

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

  resources :boards, :only => [] do
    resources :topics, :controller => "messages" do
      post 'replies' => 'messages#reply', :on => :member
    end
  end

  # additional routes for having the file name at the end of url
  resources :attachments, :only => [:show, :destroy]

  resources :groups

  map.resources :trackers, :except => :show
  resources :issue_statuses, :except => :show do
    collection do
      post 'update_issue_done_ratio'
    end
  end
  resources :custom_fields, :except => :show
  resources :enumerations, :except => :show

  match '/journals/diff/:id', :to => 'journals#diff', :via => :get

  match 'mail_handler', :controller => 'mail_handler', :action => 'index', :via => :post

  match 'admin', :controller => 'admin', :action => 'index', :via => :get
  match 'admin/projects', :controller => 'admin', :action => 'projects', :via => :get
  match 'admin/plugins', :controller => 'admin', :action => 'plugins', :via => :get
  match 'admin/info', :controller => 'admin', :action => 'info', :via => :get
  match 'admin/test_email', :controller => 'admin', :action => 'test_email', :via => :get
  match 'admin/default_configuration', :controller => 'admin', :action => 'default_configuration', :via => :post

  # TODO: What do we need the update for?
  # CHANGED: moved out of /issues
  resource :calendar, :only => [:show, :update]

  resources :documents, :only => [:show, :edit, :update, :destroy]

  # TODO: What do we need the update for?
  # CHANGED: moved out of /issues
  resource :gantt, :only => [:show, :update]

  resources :groups

  resources :issues, :except => [:new, :create] do
    collection do
      # this conflicts with the resources
      post 'index'
      post 'auto_complete' => 'auto_completes#issues'
      post 'context_menu' => 'context_menus#issues'
      get 'bulk_edit'
      post 'bulk_edit' => 'issues#bulk_update'

      # TODO: make this a real journals resource
      get 'changes' => 'journals#index', :format => :atom
      post 'preview' => 'previews#issue' # For new issues
    end

    post 'preview' => 'previews#issue' # this changes the URL from /issues/preview/:id to /issues/:id/preview

    # CHANGED: This changes the journal creation URLs. The old routes were
    # 'issues/:id/quoted' => 'journals#new'
    # 'issues/:id/edit' => 'journals#update'
    resources :journals, :only => [:index, :update, :destroy] do
      get 'diff/:field' => 'journals#diff', :as => :diff, :on => :member
    end

    # CHANGED: removed superfluous id on create
    resources :relations, :controller => 'issue_relations', :only => [:create, :destroy]

    resources :time_entries, :controller => 'timelog', :only => :index do
      get 'report' => 'time_entry_reports#report', :on => :collection
    end
  end

  resources :news, :except => [:new, :create] do
    post 'preview' => 'previews#news', :on => :collection
    post 'preview' => 'previews#news', :on => :member

    resources :comments, :only => [:create, :destroy]
  end

  resources :users do
    # TODO: resourcify these routes
    put    'memberships/:membership_id', :to => 'users#edit_membership', :as => 'membership'
    delete 'memberships/:membership_id', :to => 'users#destroy_membership'
    post   'memberships', :to => 'users#edit_membership'
  end

  get 'search' => 'search#index'

  namespace :sys do
    get 'projects' => 'sys#projects'
    post 'projects/:id/repository' => 'sys#create_project_repository', :as => 'create_project_repository'
  end
end
