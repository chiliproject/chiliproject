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

module Redmine
  module Helpers

    # Simple class to compute the start and end dates of a calendar
    class Calendar
      include Redmine::I18n
      attr_reader :startdt, :enddt

      def initialize(date, lang = current_language, period = :month)
        @date = date
        @events = []
        @ending_events_by_days = {}
        @starting_events_by_days = {}
        set_language_if_valid lang
        case period
        when :month
          @startdt = Date.civil(date.year, date.month, 1)
          @enddt = (@startdt >> 1)-1
          # starts from the first day of the week
          @startdt = @startdt - (@startdt.cwday - first_wday)%7
          # ends on the last day of the week
          @enddt = @enddt + (last_wday - @enddt.cwday)%7
        when :week
          @startdt = date - (date.cwday - first_wday)%7
          @enddt = date + (last_wday - date.cwday)%7
        else
          raise 'Invalid period'
        end
      end

      # Sets calendar events
      def events=(events)
        @events = events
        @ending_events_by_days = @events.group_by {|event| event.due_date}
        @starting_events_by_days = @events.group_by {|event| event.start_date}
      end

      # Returns events for the given day
      def events_on(day)
        ((@ending_events_by_days[day] || []) + (@starting_events_by_days[day] || [])).uniq
      end

      # Calendar current month
      def month
        @date.month
      end

      # Return the first day of week
      # 1 = Monday ... 7 = Sunday
      def first_wday
        case Setting.start_of_week.to_i
        when 1
          @first_dow ||= (1 - 1)%7 + 1
        when 6
          @first_dow ||= (6 - 1)%7 + 1
        when 7
          @first_dow ||= (7 - 1)%7 + 1
        else
          @first_dow ||= (l(:general_first_day_of_week).to_i - 1)%7 + 1
        end
      end

      def last_wday
        @last_dow ||= (first_wday + 5)%7 + 1
      end
    end
  end
end
