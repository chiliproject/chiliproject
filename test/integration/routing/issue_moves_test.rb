require File.expand_path('../../../test_helper', __FILE__)

class RoutingIssueMovesTest < ActionController::IntegrationTest
  def test_issue_relations
    assert_routing(
        { :method => 'get', :path => "/issues/move/new" },
        { :controller => 'issue_moves', :action => 'new' }
      )
    assert_routing(
        { :method => 'post', :path => "/issues/move" },
        { :controller => 'issue_moves', :action => 'create' }
      )
  end
end
