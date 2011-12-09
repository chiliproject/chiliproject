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

class CustomFieldTest < ActiveSupport::TestCase
  fixtures :custom_fields

  def test_create
    field = UserCustomField.new(:name => 'Money money money', :field_format => 'float')
    assert field.save
  end

  def test_possible_values_should_accept_an_array
    field = CustomField.new
    field.possible_values = ["One value", ""]
    assert_equal ["One value"], field.possible_values
  end

  def test_possible_values_should_accept_a_string
    field = CustomField.new
    field.possible_values = "One value"
    assert_equal ["One value"], field.possible_values
  end

  def test_possible_values_should_accept_a_multiline_string
    field = CustomField.new
    field.possible_values = "One value\nAnd another one  \r\n \n"
    assert_equal ["One value", "And another one"], field.possible_values
  end

  def test_destroy
    field = CustomField.find(1)
    assert field.destroy
  end

  def test_new_subclass_instance_should_return_an_instance
    f = CustomField.new_subclass_instance('IssueCustomField')
    assert_kind_of IssueCustomField, f
  end

  def test_new_subclass_instance_should_set_attributes
    f = CustomField.new_subclass_instance('IssueCustomField', :name => 'Test')
    assert_kind_of IssueCustomField, f
    assert_equal 'Test', f.name
  end

  def test_new_subclass_instance_with_invalid_class_name_should_return_nil
    assert_nil CustomField.new_subclass_instance('WrongClassName')
  end

  def test_new_subclass_instance_with_non_subclass_name_should_return_nil
    assert_nil CustomField.new_subclass_instance('Project')
  end
end
