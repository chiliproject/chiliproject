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

class TimeEntryActivity < Enumeration
  generator_for :name, :method => :next_name
  generator_for :type => 'TimeEntryActivity'

  def self.next_name
    @last_name ||= 'TimeEntryActivity0'
    @last_name.succ!
    @last_name
  end
end
