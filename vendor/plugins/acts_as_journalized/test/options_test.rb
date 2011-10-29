#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class OptionsTest < Test::Unit::TestCase
  context 'Configuration options' do
    setup do
      @options = {:dependent => :destroy}
      @configuration = {:class_name => 'MyCustomVersion'}

      VestalVersions::Configuration.options.clear
      @configuration.each{|k,v| VestalVersions::Configuration.send("#{k}=", v) }

      @prepared_options = User.prepare_journaled_options(@options.dup)
    end

    should 'have symbolized keys' do
      assert User.vestal_journals_options.keys.all?{|k| k.is_a?(Symbol) }
    end

    should 'combine class-level and global configuration options' do
      combined_keys = (@options.keys + @configuration.keys).map(&:to_sym).uniq
      combined_options = @configuration.symbolize_keys.merge(@options.symbolize_keys)
      assert_equal @prepared_options.slice(*combined_keys), combined_options
    end

    teardown do
      VestalVersions::Configuration.options.clear
      User.prepare_journaled_options({})
    end
  end

  context 'Given no options, configuration options' do
    setup do
      @prepared_options = User.prepare_journaled_options({})
    end

    should 'default to "VestalVersions::Version" for :class_name' do
      assert_equal 'VestalVersions::Version', @prepared_options[:class_name]
    end

    should 'default to :delete_all for :dependent' do
      assert_equal :delete_all, @prepared_options[:dependent]
    end

    should 'force the :as option value to :journaled' do
      assert_equal :journaled, @prepared_options[:as]
    end

    should 'default to [VestalVersions::Versions] for :extend' do
      assert_equal [VestalVersions::Versions], @prepared_options[:extend]
    end
  end
end
