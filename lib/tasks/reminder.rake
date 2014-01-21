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


desc <<-END_DESC
Send reminders about issues due in the next days.

Available options:
  * days     => number of days to remind about (defaults to 7)
  * tracker  => id of tracker (defaults to all trackers)
  * project  => id or identifier of project (defaults to all projects)
  * users    => comma separated list of user ids who should be reminded

Example:
  rake redmine:send_reminders days=7 users="1,23, 56" RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_reminders => :environment do
    options = {}
    options[:days] = ENV['days'].to_i if ENV['days']
    options[:project] = ENV['project'] if ENV['project']
    options[:tracker] = ENV['tracker'].to_i if ENV['tracker']
    options[:users] = (ENV['users'] || '').split(',').each(&:strip!)

    Mailer.reminders(options)
  end

  task :hide_unset_reminder_preferences => :environment do
    success, failed = 0, 0
    User.all(:include => :preference).each do |user|
      [:hide_due_date_notifications, :hide_past_due_date_notifications].each do |attr|
        user.pref[attr] = true unless user.pref.others.has_key? attr
      end
      if user.pref.save
        success += 1
      else
        failed += 1
      end
    end
    puts "Successfully updated #{success} user(s) preferences and failed to update #{failed}"
  end
end
