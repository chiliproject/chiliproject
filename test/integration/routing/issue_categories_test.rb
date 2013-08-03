require File.expand_path('../../../test_helper', __FILE__)

class RoutingIssueCategoriesTest < ActionController::IntegrationTest
  def test_issue_categories
    assert_routing(
      { :method => 'get', :path => "/projects/test/issue_categories/new" },
      { :controller => 'issue_categories', :action => 'new', :project_id => 'test'}
    )
  end
end
