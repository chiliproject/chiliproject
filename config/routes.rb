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

ChiliProject::Application.routes.draw do
  root :to => 'welcome#index', :as => 'home'
  get 'robots.txt' => 'welcome#robots'

  match '/login' => 'account#login', :as => 'signin'
  match '/logout' => 'account#login', :as => 'signout'
  resource :account, :controller => 'account', :only => [] do
    match 'register', :via => [:get, :post]
    match 'lost_password', :via => [:get, :post]
    get 'activate'
  end

  resources :p, :controller => :projects, :as => :projects do
    get 'activity' => 'activities#index' # CHANGED :id is not :project_id
    post 'archive' # should be PUT?
    get 'copy'
    post 'copy'
    get '/destroy' => 'projects#destroy', :as => 'destroy'
    post 'modules' # should be PUT?
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

    resources :issues, :only => [:new, :create] do
      collection do
        get 'report' => 'reports#issue_report'
        get 'report/:detail' => 'reports#issue_report_details'
      end
      member do
        get 'copy' => 'issues#new'
      end
    end

    # CHANGED: Members are only managed through the members controller
    # The membership methods on UserController should be removed
    resources :members, :except => :show

    resources :news, :only => [:new, :create]

    resources :queries, :only => [:new, :create]

    resource 'repository', :controller => 'repositories' do
      get 'statistics' => 'repositories#stats'

      get 'revisions'
      constraints :rev => /[a-z0-9\.\-_]+/ do
        get 'revisions/:rev' => 'repositories#revision', :as => 'revision'
        get 'revisions/:rev/diff' => 'repositories#diff', :as => 'diff'
        get 'revisions/:rev/raw/*path' => 'repositories#entry', :as => 'entry', :format => 'raw'
        # For repos without a mandatory revision, e.g. Subversion
        get 'raw/*path' => 'repositories#entry', :as => 'entry', :format => 'raw'

        # CHANGED: removed browse as alias to show
        %w[annotate changes diff entry show].each do |act|
          get "revisions/:rev/#{act}/*path" => "repositories##{act}", :as => act
          # For repos without a mandatory revision, e.g. Subversion
          get "#{act}/*path" => "repositories##{act}", :as => act
        end
      end
    end

    resources 'time_entries', :controller => 'timelog', :only => [:index, :new, :create] do
      get 'report' => 'time_entry_reports#report', :on => :collection
    end

    resources :versions do
      put 'close_completed'
      post 'status_by', :on => :member
    end

    # TODO: Adapt the actions in the WikisController
    resources :wiki do
      collection do
        get 'index' => 'wiki#show', :as => 'start_page'

        get '/index' => 'wiki#index'
        get 'date_index' => 'wiki#date_index'

        put 'update' => 'wikis#update'
        get 'export' => 'wiki#export'
      end

      member do
        post 'add_attachment'
        get 'annotate/:version' => 'wiki#annotate', :as => 'annotate'

        # To display the confirmation
        # TODO: Is this RESTful?
        match '/destroy' => 'wikis#destroy', :via => [:get, :post], :as => 'destroy'

        get 'diff/:version(/vs/:version_from)' => 'wiki#diff', :as => 'diff'
        get 'history'
        post 'preview'
        post 'protect'
        get 'rename' # TODO: this should not be needed, put this into edit
        post 'rename'
      end
    end
  end

  get 'activity' => 'activities#index'

  get 'attachments/:id(/:filename)' => 'attachments#show', :id => /\d+/, :as => 'attachment'
  get 'attachments/download/:id(/:filename)' => 'attachments#download', :id => /\d+/, :as => 'download_attachment'

  resources :boards, :only => [] do
    resources :topics, :controller => "messages" do
      post 'replies' => 'messages#reply', :on => :member
    end
  end

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
