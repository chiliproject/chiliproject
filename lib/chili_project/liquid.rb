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

require 'chili_project/liquid/liquid_ext'
require 'chili_project/liquid/filters'
require 'chili_project/liquid/tags'

module ChiliProject
  module Liquid
    Liquid::Template.file_system = FileSystem.new
  end
end