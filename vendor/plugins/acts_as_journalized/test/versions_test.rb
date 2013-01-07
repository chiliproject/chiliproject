#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class VersionsTest < ActiveSupport::TestCase
  context 'A collection of associated journals' do
    setup do
      @user, @times = TestUser.new, {}
      names = ['Steve Richert', 'Stephen Richert', 'Stephen Jobs', 'Steve Jobs']
      time = names.size.hours.ago
      names.each do |name|
        @user.update_attribute(:name, name)
        time += 1.hour
        @user.journals.last.update_attribute(:created_at, time)
        @times[@user.version] = time
      end
    end

    should 'be searchable between two valid journal values' do
      @times.keys.each do |number|
        @times.values.each do |time|
          assert_kind_of Array, @user.journals.between(number, number)
          assert_kind_of Array, @user.journals.between(number, time)
          assert_kind_of Array, @user.journals.between(time, number)
          assert_kind_of Array, @user.journals.between(time, time)
          assert !@user.journals.between(number, number).empty?
          assert !@user.journals.between(number, time).empty?
          assert !@user.journals.between(time, number).empty?
          assert !@user.journals.between(time, time).empty?
        end
      end
    end

    should 'return an empty array when searching between a valid and an invalid journal value' do
      @times.each do |number, time|
        assert_equal [], @user.journals.between(number, nil)
        assert_equal [], @user.journals.between(time, nil)
        assert_equal [], @user.journals.between(nil, number)
        assert_equal [], @user.journals.between(nil, time)
      end
    end

    should 'return an empty array when searching between two invalid journal values' do
      assert_equal [], @user.journals.between(nil, nil)
    end

    should 'be searchable before a valid journal value' do
      @times.sort.each_with_index do |(number, time), i|
        assert_equal i, @user.journals.before(number).size
        assert_equal i, @user.journals.before(time).size
      end
    end

    should 'return an empty array when searching before an invalid journal value' do
      assert_equal [], @user.journals.before(nil)
    end

    should 'be searchable after a valid journal value' do
      @times.sort.reverse.each_with_index do |(number, time), i|
        assert_equal i, @user.journals.after(number).size
        assert_equal i, @user.journals.after(time).size
      end
    end

    should 'return an empty array when searching after an invalid journal value' do
      assert_equal [], @user.journals.after(nil)
    end

    should 'be fetchable by journal number' do
      @times.keys.each do |number|
        assert_kind_of Journal, @user.journals.at(number)
        assert_equal number, @user.journals.at(number).version
      end
    end

    should "be fetchable by the exact time of a journal's creation" do
      @times.each do |number, time|
        assert_kind_of Journal, @user.journals.at(time)
        assert_equal number, @user.journals.at(time).version
      end
    end

    should "be fetchable by any time after the model's creation" do
      @times.each do |number, time|
        assert_kind_of Journal, @user.journals.at(time + 30.minutes)
        assert_equal number, @user.journals.at(time + 30.minutes).version
      end
    end

    should "return nil when fetching a time before the model's creation" do
      creation = @times.values.min
      assert_nil @user.journals.at(creation - 1.second)
    end

    should 'be fetchable by an association extension method' do
      assert_kind_of Journal, @user.journals.at(:first)
      assert_kind_of Journal, @user.journals.at(:last)
      assert_equal @times.keys.min, @user.journals.at(:first).version
      assert_equal @times.keys.max, @user.journals.at(:last).version
    end

    should 'be fetchable by a journal object' do
      @times.keys.each do |number|
        journal = @user.journals.at(number)
        assert_kind_of Journal, journal
        assert_kind_of Journal, @user.journals.at(journal)
        assert_equal number, @user.journals.at(journal).version
      end
    end

    should 'return nil when fetching an invalid journal value' do
      assert_nil @user.journals.at(nil)
    end

    should 'provide a journal number for any given numeric journal value' do
      @times.keys.each do |number|
        assert_kind_of Fixnum, @user.journals.journal_at(number)
        assert_kind_of Fixnum, @user.journals.journal_at(number + 0.5)
        assert_equal @user.journals.journal_at(number), @user.journals.journal_at(number + 0.5)
      end
    end

    should 'return nil when providing a journal number for an invalid tag' do
      assert_nil @user.journals.journal_at('INVALID')
    end

    should 'provide a journal number of a journal corresponding to an association extension method' do
      assert_kind_of Journal, @user.journals.at(:first)
      assert_kind_of Journal, @user.journals.at(:last)
      assert_equal @times.keys.min, @user.journals.journal_at(:first)
      assert_equal @times.keys.max, @user.journals.journal_at(:last)
    end

    should 'return nil when providing a journal number for an invalid association extension method' do
      assert_nil @user.journals.journal_at(:INVALID)
    end

    should "provide a journal number for any time after the model's creation" do
      @times.each do |number, time|
        assert_kind_of Fixnum, @user.journals.journal_at(time + 30.minutes)
        assert_equal number, @user.journals.journal_at(time + 30.minutes)
      end
    end

    should "provide a journal number of 1 for a time before the model's creation" do
      creation = @times.values.min
      assert_equal 1, @user.journals.journal_at(creation - 1.second)
    end

    should 'provide a journal number for a given journal object' do
      @times.keys.each do |number|
        journal = @user.journals.at(number)
        assert_kind_of Journal, journal
        assert_kind_of Fixnum, @user.journals.journal_at(journal)
        assert_equal number, @user.journals.journal_at(journal)
      end
    end
  end
end
