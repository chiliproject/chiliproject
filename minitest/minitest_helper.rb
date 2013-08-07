# Load Rails environment
ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)

# Load MiniTest
require "minitest/autorun"
require 'capybara/rails'
require "minitest/matchers"
require "valid_attribute"

require 'active_support/testing/setup_and_teardown'
class MiniTest::Spec
  include ActiveSupport::Callbacks
  define_callbacks :setup, :teardown
  include ActiveSupport::Testing::SetupAndTeardown::ForMiniTest
  extend ActiveSupport::Testing::SetupAndTeardown::ClassMethods
  # include ActiveSupport::Testing::SetupAndTeardown

  alias_method :method_name, :__name__ if method_defined? :__name__
end

Turn.config do |c|
  c.format = :dot
  c.natural = true
end

Setting.use_caching = false

Dir[Rails.root.join("minitest", "support", "**", "*.rb")].each do |file|
  require file
end
