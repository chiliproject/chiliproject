#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# use RACK_ENV if we are running as a simple rack app
ENV['RAILS_ENV'] ||= ENV['RACK_ENV'] if ENV['RACK_ENV']

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.14' unless defined? RAILS_GEM_VERSION

# this is replaced by config.encoding = "utf-8" in rails3
if RUBY_VERSION >= '1.9'
  Encoding.default_external = 'UTF-8'
  Encoding.default_internal = 'UTF-8'
else
  $KCODE='UTF-8'
end

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load Engine plugin if available
begin
  require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
rescue LoadError
  # Not available
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here

  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for sweepers
  config.autoload_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Liquid drops
  config.autoload_paths += %W( #{RAILS_ROOT}/app/drops )

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :journal_observer, :message_observer, :issue_observer, :news_observer, :document_observer, :comment_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc

  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in configuration.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  # Insert vendor/chiliproject_plugins at the top of the plugin load paths
  config.plugin_paths.insert(0, File.join(Rails.root, "vendor", "chiliproject_plugins"))

  # Use redmine's custom plugin locater
  require File.join(RAILS_ROOT, "lib/redmine_plugin_locator")
  config.plugin_locators << RedminePluginLocator

  # Load any local configuration that is kept out of source control
  # (e.g. patches).
  if File.exists?(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
    instance_eval File.read(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
  end
end
