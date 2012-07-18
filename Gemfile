# -*- coding: utf-8 -*-
source "https://rubygems.org"

gem "rails", "3.2.8"

gem "json", "~> 1.7.7"
gem "coderay", "~> 1.0.0"
gem "rubytree", "~> 0.5.2", :require => 'tree'
gem "rdoc", ">= 2.4.2"
gem "liquid", "~> 2.3.0"
gem "acts-as-taggable-on", "= 2.1.0"
gem 'gravatarify', '~> 3.0.0'
# Needed only on RUBY_VERSION = 1.8, ruby 1.9+ compatible interpreters should bring their csv
gem "fastercsv", "~> 1.5.0", :platforms => [:ruby_18, :jruby, :mingw_18]
# TODO rails-3.2: review the core changes to awesome_nested_set and decide on actions
gem 'awesome_nested_set'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :test do
  gem 'shoulda', '~> 2.10.3'
  # Shoulda doesn't work nice on 1.9.3 and seems to need test-unit explicitely…
  gem 'test-unit', :platforms => [:mri_19]
  gem 'edavis10-object_daddy', :require => 'object_daddy'
  gem 'mocha', '0.12.1'
  # capybara 2 drops ruby 1.8.7 compatibility
  gem 'capybara', '< 2.0.0'
  # nokogiri 1.6 requires ruby 1.9.2 or higher
  gem 'nokogiri', '< 1.6.0'
  gem 'coveralls', :require => false
end

group :ldap do
  gem "net-ldap", '~> 0.3.1'
end

group :openid do
  gem "ruby-openid", '~> 2.1.4', :require => 'openid'
end

group :rmagick do
  gem "rmagick", ">= 1.15.17"
  # Older distributions might not have a sufficiently new ImageMagick version
  # for the current rmagick release (current rmagick is rmagick 2, which
  # requires ImageMagick 6.4.9 or later). If this is the case for you, comment
  # the line above this comment block and uncomment the one underneath it to
  # get an rmagick version known to work on older distributions.
  #
  # The following distributions are known to *not* ship with a usable
  # ImageMagick version. There might be additional ones.
  #   * Ubuntu 9.10 and older
  #   * Debian Lenny 5.0 and older
  #   * CentOS 5 and older
  #   * RedHat 5 and older
  #
  #gem "rmagick", "< 2.0.0"
end

# Use the commented pure ruby gems, if you have not the needed prerequisites on
# board to compile the native ones.  Note, that their use is discouraged, since
# their integration is propbably not that well tested and their are slower in
# orders of magnitude compared to their native counterparts. You have been
# warned.

platforms :mri, :mingw, :rbx do
  group :mysql2 do
    gem "mysql2", "~> 0.2.7"
  end

  group :postgres do
    gem "pg"
    #   gem "postgres-pr"
  end

  group :sqlite do
    gem "sqlite3"
  end
end

platforms :mri_18, :mingw_18 do
  group :mysql do
    gem "mysql"
    #   gem "ruby-mysql"
  end
end

platforms :jruby do
  gem "jruby-openssl"

  group :mysql do
    gem "activerecord-jdbcmysql-adapter"
  end

  group :postgres do
    gem "activerecord-jdbcpostgresql-adapter"
  end

  group :sqlite do
    gem "activerecord-jdbcsqlite3-adapter"
  end
end

# Load a "local" Gemfile
gemfile_local = File.join(File.dirname(__FILE__), "Gemfile.local")
if File.readable?(gemfile_local)
  puts "Loading #{gemfile_local} ..." if $DEBUG
  instance_eval(File.read(gemfile_local))
end

# Load plugins' Gemfiles
["plugins", "chiliproject_plugins"].each do |plugin_path|
  Dir.glob File.expand_path("../vendor/#{plugin_path}/*/Gemfile", __FILE__) do |file|
    puts "Loading #{file} ..." if $DEBUG # `ruby -d` or `bundle -v`
    instance_eval File.read(file)
  end
end
