#-- encoding: UTF-8
require File.expand_path('../test_helper', File.dirname(__FILE__))

class BackwardsCompatibilityTest < Test::Unit::TestCase
  def test_rails_module_plugin_method_should_delegate_to_engines_plugins
    assert_nothing_raised { Rails.plugins }
    assert_equal Engines.plugins, Rails.plugins 
  end
end