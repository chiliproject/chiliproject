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

require File.expand_path('../../test_helper', __FILE__)

class PrincipalDropTest < ActiveSupport::TestCase
  def setup
    @principal = Principal.generate!
    @drop = @principal.to_liquid
  end


  context "#name" do
    should "return the name" do
      assert_equal @principal.name, @drop.name
    end
  end
end
