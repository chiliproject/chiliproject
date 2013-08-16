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

class Document < ActiveRecord::Base
  include Redmine::SafeAttributes
  belongs_to :project
  belongs_to :category, :class_name => "DocumentCategory", :foreign_key => "category_id"
  acts_as_attachable :delete_permission => :manage_documents

  acts_as_journalized :event_title => Proc.new {|o| "#{l(:label_document)}: #{o.title}"},
      :event_url => Proc.new {|o| {:controller => 'documents', :action => 'show', :id => o.journaled_id}},
      :event_author => (Proc.new do |o|
        o.attachments.find(:first, :order => "#{Attachment.table_name}.created_on ASC").try(:author)
      end)

  acts_as_searchable :columns => ['title', "#{table_name}.description"], :include => :project
  acts_as_watchable

  validates_presence_of :project, :title, :category
  validates_length_of :title, :maximum => 60

  named_scope :visible, lambda {|*args| { :include => :project,
                                          :conditions => Project.allowed_to_condition(args.first || User.current, :view_documents) } }

  safe_attributes 'category_id', 'title', 'description'

  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_documents, project)
  end

  def after_initialize
    if new_record? && DocumentCategory.default.present?
      # FIXME: on Rails 3 use this instead
      # self.category ||= DocumentCategory.default
      self.category_id = DocumentCategory.default.id if self.category_id == 0
    end
  end

  def updated_on
    unless @updated_on
      a = attachments.find(:first, :order => 'created_on DESC')
      @updated_on = (a && a.created_on) || created_on
    end
    @updated_on
  end

  def recipients
    mails = super # from acts_as_event
    mails += watcher_recipients
    mails.uniq
  end
end
