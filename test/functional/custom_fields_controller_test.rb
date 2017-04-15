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
require 'custom_fields_controller'

# Re-raise errors caught by the controller.
class CustomFieldsController; def rescue_action(e) raise e end; end

class CustomFieldsControllerTest < ActionController::TestCase
  fixtures :custom_fields, :trackers, :users

  def setup
    @controller = CustomFieldsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user_id] = 1
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_new_issue_custom_field
    get :new, :type => 'IssueCustomField'
    assert_response :success
    assert_template 'new'
    assert_tag :input, :attributes => {:name => 'custom_field[name]'}
    assert_tag :select,
      :attributes => {:name => 'custom_field[field_format]'},
      :child => {
        :tag => 'option',
        :attributes => {:value => 'user'},
        :content => 'User'
      }
    assert_tag :select,
      :attributes => {:name => 'custom_field[field_format]'},
      :child => {
        :tag => 'option',
        :attributes => {:value => 'version'},
        :content => 'Version'
      }
    assert_tag :input, :attributes => {:name => 'type', :value => 'IssueCustomField'}
  end

  def test_new_with_invalid_custom_field_class_should_render_404
    get :new, :type => 'UnknownCustomField'
    assert_response 404
  end

  def test_create_list_custom_field
    assert_difference 'CustomField.count' do
      post :create, :type => "IssueCustomField",
                 :custom_field => {:name => "test_post_new_list",
                                   :default_value => "",
                                   :min_length => "0",
                                   :searchable => "0",
                                   :regexp => "",
                                   :is_for_all => "1",
                                   :possible_values => "0.1\n0.2\n",
                                   :max_length => "0",
                                   :is_filter => "0",
                                   :is_required =>"0",
                                   :field_format => "list",
                                   :tracker_ids => ["1", ""]}
    end
    assert_redirected_to '/custom_fields?tab=IssueCustomField'
    field = IssueCustomField.find_by_name('test_post_new_list')
    assert_not_nil field
    assert_equal ["0.1", "0.2"], field.possible_values
    assert_equal 1, field.trackers.size
  end

  def test_create_with_failure
    assert_no_difference 'CustomField.count' do
      post :create, :type => "IssueCustomField", :custom_field => {:name => ''}
    end
    assert_response :success
    assert_template 'new'
  end

  def test_edit
    get :edit, :id => 1
    assert_response :success
    assert_template 'edit'
    assert_tag 'input', :attributes => {:name => 'custom_field[name]', :value => 'Database'}
  end

  def test_edit_invalid_custom_field_should_render_404
    get :edit, :id => 99
    assert_response 404
  end

  def test_update
    put :update, :id => 1, :custom_field => {:name => 'New name'}
    assert_redirected_to '/custom_fields?tab=IssueCustomField'

    field = CustomField.find(1)
    assert_equal 'New name', field.name
  end

  def test_update_with_failure
    put :update, :id => 1, :custom_field => {:name => ''}
    assert_response :success
    assert_template 'edit'
  end

  def test_destroy
    custom_values_count = CustomValue.count(:conditions => {:custom_field_id => 1})
    assert custom_values_count > 0

    assert_difference 'CustomField.count', -1 do
      assert_difference 'CustomValue.count', - custom_values_count do
        delete :destroy, :id => 1
      end
    end

    assert_redirected_to '/custom_fields?tab=IssueCustomField'
    assert_nil CustomField.find_by_id(1)
    assert_nil CustomValue.find_by_custom_field_id(1)
  end
end
