#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class OptionsTest < ActiveSupport::TestCase
  context 'Configuration options' do
    setup do
      @options = {:dependent => :destroy}
      @configuration = {:class_name => 'MyCustomVersion'}

      Redmine::Acts::Journalized::Configuration.options.clear
      @configuration.each{|k,v| Redmine::Acts::Journalized::Configuration.send("#{k}=", v) }

      @prepared_options = TestUser.prepare_journaled_options(@options.dup)
    end

    should 'have symbolized keys' do
      assert TestUser.vestal_journals_options.keys.all?{|k| k.is_a?(Symbol) }
    end

    should 'combine class-level and global configuration options' do
      combined_keys = (@options.keys + @configuration.keys).map(&:to_sym).uniq
      combined_options = @configuration.symbolize_keys.merge(@options.symbolize_keys)
      assert_equal @prepared_options.slice(*combined_keys), combined_options
    end

    teardown do
      Redmine::Acts::Journalized::Configuration.options.clear
      TestUser.prepare_journaled_options({})
    end
  end

  context 'Given no options, configuration options' do
    setup do
      @prepared_options = TestUser.prepare_journaled_options({})
    end

    should 'default to "TestUserJournal" for :class_name' do
      assert_equal 'TestUserJournal', @prepared_options[:class_name]
    end

    should 'default to :delete_all for :dependent' do
      assert_equal :delete_all, @prepared_options[:dependent]
    end

    should 'default to [Redmine::Acts::Journalized::Versions] for :extend' do
      assert_equal [Redmine::Acts::Journalized::Versions], @prepared_options[:extend]
    end
  end
end
