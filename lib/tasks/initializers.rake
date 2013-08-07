#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

desc 'Generates a secret token for the application.'
task :generate_secret_token do
  path = Rails.root.join('config', 'initializers', 'session_store.rb')
  secret = SecureRandom.hex(40)
  File.open(path, 'w') do |f|
    f.write <<"EOF"
# This file was generated by 'rake generate_secret_token',
# and should not be made visible to public.
# If you have a load-balancing ChiliProject cluster, you will need to use the
# same version of this file on each machine. And be sure to restart your
# server when you modify this file.

# Your secret key for verifying cookie session data integrity. If you
# change this key, all old sessions will become invalid! Make sure the
# secret is at least 30 characters and all random, no regular words or
# you'll be exposed to dictionary attacks.
ChiliProject::Application.config.secret_token = '#{secret}'
EOF
  end
end

task "generate_session_store" do
  fail <<-EOF

The rake task generate_session_store has been removed in ChiliProject 4.0.
Please use `rake generate_secret_token` instead.
EOF
end
