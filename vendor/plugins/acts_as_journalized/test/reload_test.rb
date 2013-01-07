#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class ReloadTest < ActiveSupport::TestCase
  context 'Reloading a reverted model' do
    setup do
      @user = TestUser.create(:name => 'Steve Richert')
      first_version = @user.version
      @user.update_attribute(:last_name, 'Jobs')
      @last_version = @user.version
      @user.revert_to(first_version)
    end

    should 'reset the journal number to the most recent journal' do
      assert_not_equal @last_version, @user.version
      @user.reload
      assert_equal @last_version, @user.version
    end
  end
end
