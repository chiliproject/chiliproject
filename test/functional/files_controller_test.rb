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

require File.expand_path('../../test_helper', __FILE__)

class FilesControllerTest < ActionController::TestCase
  fixtures :attachments,
           :auth_sources,
           :boards,
           :changes,
           :changesets,
           :comments,
           :custom_fields,
           :custom_fields_projects,
           :custom_fields_trackers,
           :custom_values,
           :documents,
           :enabled_modules,
           :enumerations,
           :groups_users,
           :issue_categories,
           :issue_relations,
           :issue_statuses,
           :issues,
           :journals,
           :member_roles,
           :members,
           :messages,
           :news,
           :projects,
           :projects_trackers,
           :queries,
           :repositories,
           :roles,
           :time_entries,
           :tokens,
           :trackers,
           :user_preferences,
           :users,
           :versions,
           :watchers,
           :wiki_contents,
           :wiki_pages,
           :wikis,
           :workflows

  def setup
    @controller = FilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = nil
    Setting.default_language = 'en'
  end

  def test_index
    get :index, :project_id => 1
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:containers)

    # file attached to the project
    assert_tag :a, :content => 'project_file.zip',
                   :attributes => { :href => '/attachments/download/8/project_file.zip' }

    # file attached to a project's version
    assert_tag :a, :content => 'version_file.zip',
                   :attributes => { :href => '/attachments/download/9/version_file.zip' }
  end

  def test_create_file
    set_tmp_attachments_directory
    @request.session[:user_id] = 2
    Setting.notified_events = ['file_added']
    ActionMailer::Base.deliveries.clear

    assert_difference 'Attachment.count' do
      post :create, :project_id => 1, :version_id => '',
           :attachments => {'1' => {'file' => uploaded_test_file('testfile.txt', 'text/plain')}}
      assert_response :redirect
    end
    assert_redirected_to '/projects/ecookbook/files'
    a = Attachment.find(:first, :order => 'created_on DESC')
    assert_equal 'testfile.txt', a.filename
    assert_equal Project.find(1), a.container

    mail = ActionMailer::Base.deliveries.last
    assert_not_nil mail
    assert_equal "[eCookbook] New file", mail.subject
    assert_mail_body_match 'testfile.txt', mail
  end

  def test_create_version_file
    set_tmp_attachments_directory
    @request.session[:user_id] = 2
    Setting.notified_events = ['file_added']

    assert_difference 'Attachment.count' do
      post :create, :project_id => 1, :version_id => '2',
           :attachments => {'1' => {'file' => uploaded_test_file('testfile.txt', 'text/plain')}}
      assert_response :redirect
    end
    assert_redirected_to '/projects/ecookbook/files'
    a = Attachment.find(:first, :order => 'created_on DESC')
    assert_equal 'testfile.txt', a.filename
    assert_equal Version.find(2), a.container
  end

end
