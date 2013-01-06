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

class ExportPdf < ActiveRecord::Migration
  # model removed
  class Permission < ActiveRecord::Base; end

  def self.up
    Permission.create :controller => "projects", :action => "export_issues_pdf", :description => "label_export_pdf", :sort => 1002, :is_public => true, :mail_option => 0, :mail_enabled => 0
    Permission.create :controller => "issues", :action => "export_pdf", :description => "label_export_pdf", :sort => 1015, :is_public => true, :mail_option => 0, :mail_enabled => 0
  end

  def self.down
    Permission.find(:first, :conditions => ["controller=? and action=?", 'projects', 'export_issues_pdf']).destroy
    Permission.find(:first, :conditions => ["controller=? and action=?", 'issues', 'export_pdf']).destroy
  end
end
