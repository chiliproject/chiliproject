#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class VersionTest < ActiveSupport::TestCase
  context 'Versions' do
    setup do
      @user = TestUser.create(:name => 'Stephen Richert')
      @user.update_attribute(:name, 'Steve Jobs')
      @user.update_attribute(:last_name, 'Richert')
      @first_journal, @last_journal = @user.journals.first, @user.journals.last
    end

    should 'be comparable to another journal based on journal number' do
      assert @first_journal == @first_journal
      assert @last_journal == @last_journal
      assert @first_journal != @last_journal
      assert @last_journal != @first_journal
      assert @first_journal < @last_journal
      assert @last_journal > @first_journal
      assert @first_journal <= @last_journal
      assert @last_journal >= @first_journal
    end

    should "not equal a separate model's journal with the same number" do
      user = TestUser.create(:name => 'Stephen Richert')
      user.update_attribute(:name, 'Steve Jobs')
      user.update_attribute(:last_name, 'Richert')
      first_journal, last_journal = user.journals.first, user.journals.last
      assert_not_equal @first_journal, first_journal
      assert_not_equal @last_journal, last_journal
    end

    should 'default to ordering by version when finding through association' do
      order = @user.journals.send(:scope, :find)[:order]
      assert_equal 'journals.version ASC', order
    end

    should 'return true for the "initial?" method when the journal version is 1' do
      journal = @user.journals.build(:version => 1)
      assert_equal 1, journal.version
      assert_equal true, journal.initial?
    end
  end
end
