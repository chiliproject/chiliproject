#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class UsersTest < ActiveSupport::TestCase
  fixtures :users

  context 'The user responsible for an update' do
    setup do
      @updated_by = User.find 1
      @user = TestUser.create(:name => 'Steve Richert')
    end

    should 'default to User.current' do
      @user.update_attributes(:first_name => 'Stephen')
      assert_equal User.current, @user.journals.last.user
    end

    should 'accept and return a User' do
      @user.update_attributes(:first_name => 'Stephen', :journal_user => @updated_by)
      assert_equal @updated_by, @user.journals.last.user
    end
  end
end
