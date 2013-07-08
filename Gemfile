# -*- coding: utf-8 -*-
source "https://rubygems.org"

gem "rails", "~> 3.1.0"

gem "json", "~> 1.7.7"
gem "coderay", "~> 1.0.0"
gem "i18n"
gem "rubytree", "~> 0.5.2", :require => 'tree'
gem "rdoc", ">= 2.4.2"
gem "liquid", "~> 2.3.0"
gem "acts-as-taggable-on", "= 2.1.0"
gem 'gravatarify', '~> 3.0.0'
gem "tzinfo", "~> 0.3.31" # Fixes #903. Not required for Rails >= 3.2

gem "prototype_legacy_helper", '0.0.0', :git => 'git://github.com/rails/prototype_legacy_helper.git'
# TODO rails-3.2: review the core changes to awesome_nested_set and decide on actions
gem 'awesome_nested_set'

## TODO rails-3.1: review the core changes to open_id_authentication and decide on actions
gem "open_id_authentication",
    :git => 'git://github.com/ndbradley730/open_id_authentication.git',
    :branch => 'controllermethods_name_error'

gem "ruby-prof"

gem 'jquery-rails'

group :test do
  gem 'shoulda', '~> 2.11.0'
  # Shoulda doesn't work nice on 1.9.3 and seems to need test-unit explicitely…
  gem 'test-unit', :platforms => [:mri_19]
  gem 'mocha'
  gem 'capybara'
  gem 'nokogiri'
  gem 'coveralls', :require => false

  gem 'minitest'
  gem 'turn'
  gem 'minitest-matchers'
  gem 'valid_attribute'
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
  # keep mysql group as backwards compat
  group :mysql2, :mysql do
    gem "mysql2"
  end

  group :postgres do
    gem "pg"
    #   gem "postgres-pr"
  end

  group :sqlite do
    gem "sqlite3"
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
