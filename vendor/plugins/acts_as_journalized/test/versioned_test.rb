#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class VersionedTest < ActiveSupport::TestCase
  context 'ActiveRecord models' do
    should 'respond to the "journaled?" method' do
      assert ActiveRecord::Base.respond_to?(:journaled?)
      assert TestUser.respond_to?(:journaled?)
    end

    should 'return true for the "journaled?" method if the model is journaled' do
      assert_equal true, TestUser.journaled?
    end

    should 'return false for the "journaled?" method if the model is not journaled' do
      assert_equal false, ActiveRecord::Base.journaled?
    end
  end
end
