#-- encoding: UTF-8
require File.join(File.dirname(__FILE__), 'test_helper')

class ConfigurationTest < ActiveSupport::TestCase
  context 'Global configuration options' do
    setup do
      module Extension; end
      
      @options = {
        'class_name' => 'CustomVersion',
        :extend => Extension,
        :as => :parent
      }
      
      Redmine::Acts::Journalized.configure do |config|
        @options.each do |key, value|
          config.send("#{key}=", value)
        end
      end

      @configuration = Redmine::Acts::Journalized::Configuration.options
    end

    should 'should be a hash' do
      assert_kind_of Hash, @configuration
    end

    should 'have symbol keys' do
      assert @configuration.keys.all?{|k| k.is_a?(Symbol) }
    end

    should 'store values identical to those given' do
      assert_equal @options.symbolize_keys, @configuration
    end

    teardown do
      Redmine::Acts::Journalized::Configuration.options.clear
    end
  end
end
