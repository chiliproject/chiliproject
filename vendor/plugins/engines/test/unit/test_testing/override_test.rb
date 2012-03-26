#-- encoding: UTF-8
require File.expand_path(File.join(*%w[.. .. test_helper]), File.dirname(__FILE__))

class OverrideTest < ActiveSupport::TestCase
  def test_overrides_from_the_application_should_work
    assert true, "overriding plugin tests from the application should work"
  end
end