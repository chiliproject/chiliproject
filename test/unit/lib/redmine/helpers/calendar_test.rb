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
require File.expand_path('../../../../../test_helper', __FILE__)

class CalendarTest < ActiveSupport::TestCase

  def test_monthly
    c = Redmine::Helpers::Calendar.new(Date.today, :fr, :month)
    assert_equal [1, 7], [c.startdt.cwday, c.enddt.cwday]

    c = Redmine::Helpers::Calendar.new('2007-07-14'.to_date, :fr, :month)
    assert_equal ['2007-06-25'.to_date, '2007-08-05'.to_date], [c.startdt, c.enddt]

    c = Redmine::Helpers::Calendar.new(Date.today, :en, :month)
    assert_equal [7, 6], [c.startdt.cwday, c.enddt.cwday]
  end

  def test_weekly
    c = Redmine::Helpers::Calendar.new(Date.today, :fr, :week)
    assert_equal [1, 7], [c.startdt.cwday, c.enddt.cwday]

    c = Redmine::Helpers::Calendar.new('2007-07-14'.to_date, :fr, :week)
    assert_equal ['2007-07-09'.to_date, '2007-07-15'.to_date], [c.startdt, c.enddt]

    c = Redmine::Helpers::Calendar.new(Date.today, :en, :week)
    assert_equal [7, 6], [c.startdt.cwday, c.enddt.cwday]
  end

  def test_monthly_start_day
    [1, 6, 7].each do |day|
      with_settings :start_of_week => day do
        c = Redmine::Helpers::Calendar.new(Date.today, :en, :month)
        assert_equal day , c.startdt.cwday
        assert_equal (day + 5) % 7 + 1, c.enddt.cwday
      end
    end
  end

  def test_weekly_start_day
    [1, 6, 7].each do |day|
      with_settings :start_of_week => day do
        c = Redmine::Helpers::Calendar.new(Date.today, :en, :week)
        assert_equal day, c.startdt.cwday
        assert_equal (day + 5) % 7 + 1, c.enddt.cwday
      end
    end
  end
end
