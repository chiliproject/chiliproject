# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

#This is for the deprecation warning on older rubygem versions on version_requirements
module Rails
    #See lib/gems/1.8/gems/rails-2.3.5/lib/rails/gem_dependency.rb
    class GemDependency < Gem::Dependency
      def dependencies
        return [] if framework_gem?
        return [] unless installed?
        specification.dependencies.reject do |dependency|
          dependency.type == :development
        end.map do |dependency|
          GemDependency.new(dependency.name,
                            :requirement => (dependency.respond_to?(:requirement) ?
                             dependency.requirement :
                             dependency.version_requirements))
        end
      end

      if method_defined?(:requirement)
        #rubygem > 1.5
        def requirement
          req = super
          req unless req == Gem::Requirement.default
        end
      else
        #rubygem < 1.5
        def requirement
          req = version_requirements
          req unless req == Gem::Requirement.default
        end
      end
    end
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
  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :message_observer, :issue_observer, :journal_observer, :news_observer, :document_observer, :wiki_content_observer

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby
  
  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  config.gem 'rubytree', :lib => 'tree'
  
  # Load any local configuration that is kept out of source control
  # (e.g. gems, patches).
  if File.exists?(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
    instance_eval File.read(File.join(File.dirname(__FILE__), 'additional_environment.rb'))
  end
end
