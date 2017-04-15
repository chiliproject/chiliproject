require File.expand_path('../../../test_helper', __FILE__)

class RoutingIssueCategoriesTest < ActionController::IntegrationTest
  def test_issue_categorie
    assert_routing(
      { :method => 'get', :path => "/projects/test/issue_categories/new" },
      { :controller => 'issue_categories', :action => 'new', :project_id => 'test'}
    )
    assert_routing(
      { :method => 'post', :path => "/projects/test/issue_categories/new" },
      { :controller => 'issue_categories', :action => 'new', :project_id => 'test'}
    )
  end
end
