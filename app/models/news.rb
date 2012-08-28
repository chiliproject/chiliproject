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

class News < ActiveRecord::Base
  include Redmine::SafeAttributes
  belongs_to :project
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  has_many :comments, :as => :commented, :dependent => :delete_all, :order => "created_on"

  validates_presence_of :title, :description
  validates_length_of :title, :maximum => 60
  validates_length_of :summary, :maximum => 255

  acts_as_journalized :event_url => Proc.new {|o| {:controller => 'news', :action => 'show', :id => o.journaled_id} },
    :event_description => :description
  acts_as_searchable :columns => ["#{table_name}.title", "#{table_name}.summary", "#{table_name}.description"], :include => :project
  acts_as_watchable

  after_create :add_author_as_watcher

  def self.visible(user=User.current)
    joins(:project).where(Project.allowed_to_condition(user, :view_news))
  end

  # returns latest news for projects visible by user
  def self.latest(user=User.current, count=5)
    visible.joins(:author).limit(count).order('created_on DESC')
  end

  safe_attributes 'title', 'summary', 'description'

  def visible?(user=User.current)
    !user.nil? && user.allowed_to?(:view_news, project)
  end

  # Returns true if the news can be commented by user
  def commentable?(user=User.current)
    user.allowed_to?(:comment_news, project)
  end


  private

  def add_author_as_watcher
    Watcher.create(:watchable => self, :user => author)
  end
end
