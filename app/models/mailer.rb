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

require 'ar_condition'

class Mailer < ActionMailer::Base
  layout 'mailer'
  helper :application
  helper :issues
  helper :journals
  helper :custom_fields

  include Redmine::I18n

  self.prepend_view_path "app/views/mailer"

  def self.default_url_options
    { :host => Setting.host_name, :protocol => Setting.protocol }
  end

  # Builds a tmail object used to email a recipient of the added issue.
  #
  # Example:
  #   issue_add(issue, 'user@example.com') => tmail object
  #   Mailer.deliver_issue_add(issue, 'user@example.com') => sends an email to 'user@example.com'
  def issue_add(issue, recipient)
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login,
                    'Type' => "Issue"
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id issue
    @author = issue.author
    @issue = issue
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue)
    recipients = issue.recipients
    cc = issue.watcher_recipients - recipients
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] (#{issue.status.name}) #{issue.subject}"
  end

  # Builds a tmail object used to email recipients of the edited issue.
  #
  # Example:
  #   issue_edit(journal, 'user@example.com') => tmail object
  #   Mailer.deliver_issue_edit(journal, 'user@example.com') => sends an email to issue recipients
  def issue_edit(journal, recipient)
    issue = journal.journaled.reload
    redmine_headers 'Project' => issue.project.identifier,
                    'Issue-Id' => issue.id,
                    'Issue-Author' => issue.author.login,
                    'Type' => "Issue"
    redmine_headers 'Issue-Assignee' => issue.assigned_to.login if issue.assigned_to
    message_id journal
    references issue
    @author = journal.user
    recipients = issue.recipients
    # Watchers in cc
    cc = issue.watcher_recipients - recipients
    s = "[#{issue.project.name} - #{issue.tracker.name} ##{issue.id}] "
    s << "(#{issue.status.name}) " if journal.details['status_id']
    s << issue.subject
    @issue = issue
    @journal = journal
    @issue_url = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")
    mail :to => recipients,
      :cc => cc,
      :subject => s
  end

  def reminder(user, issues, days)
    redmine_headers 'Type' => "Issue"
    set_language_if_valid user.language
    @issues = issues
    @days = days
    @issues_url = url_for(:controller => 'issues', :action => 'index',
                                :set_filter => 1, :assigned_to_id => user.id,
                                :sort => 'due_date:asc')
    mail :to => user.mail,
      :subject => l(:mail_subject_reminder, :count => issues.size, :days => days)
  end

  # Builds a tmail object used to email users belonging to the added document's project.
  #
  # Example:
  #   document_added(document) => tmail object
  #   Mailer.deliver_document_added(document) => sends an email to the document's project recipients
  def document_added(document, recipient)
    redmine_headers 'Project' => document.project.identifier
    @author = User.current
    @document = document
    @document_url = url_for(:controller => 'documents', :action => 'show', :id => document)
    mail :to => document.recipients,
      :subject => "[#{document.project.name}] #{l(:label_document_new)}: #{document.title}"
  end

  # Builds a tmail object used to email recipients of a project when an attachements are added.
  #
  # Example:
  #   document_added(document, 'test@example.com') => tmail object
  #   Mailer.deliver_document_added(document, 'test@example.com') => sends an email to the document's project recipients
  def attachments_added(attachments, recipient)
    container = attachments.first.container
    added_to = ''
    added_to_url = ''
    case container.class.name
    when 'Project'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container)
      added_to = "#{l(:label_project)}: #{container}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Version'
      added_to_url = url_for(:controller => 'files', :action => 'index', :project_id => container.project)
      added_to = "#{l(:label_version)}: #{container.name}"
      recipients = container.project.notified_users.select {|user| user.allowed_to?(:view_files, container.project)}.collect  {|u| u.mail}
    when 'Document'
      added_to_url = url_for(:controller => 'documents', :action => 'show', :id => container.id)
      added_to = "#{l(:label_document)}: #{container.title}"
      recipients = container.recipients
    end
    redmine_headers 'Project' => container.project.identifier
    @attachments = attachments
    @added_to = added_to
    @added_to_url = added_to_url
    mail :to => recipients,
      :subject => "[#{container.project.name}] #{l(:label_attachment_new)}"
  end

  # Builds a tmail object used to email recipients of a news' project when a news item is added.
  #
  # Example:
  #   news_added(news) => tmail object
  #   Mailer.deliver_news_added(news) => sends an email to the news' project recipients
  def news_added(news, recipient)
    redmine_headers 'Project' => news.project.identifier,
                    'Type' => "News"
    message_id news
    @news = news
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    mail :to => news.recipients,
      :subject => "[#{news.project.name}] #{l(:label_news)}: #{news.title}"
  end

  # Builds a tmail object used to email recipients of a news' project when a news comment is added.
  #
  # Example:
  #   news_comment_added(comment) => tmail object
  #   Mailer.news_comment_added(comment) => sends an email to the news' project recipients
  def news_comment_added(comment)
    news = comment.commented
    redmine_headers 'Project' => news.project.identifier
    message_id comment
    @news = news
    @comment = comment
    @news_url = url_for(:controller => 'news', :action => 'show', :id => news)
    mail :to => news.recipients,
     :cc => news.watcher_recipients,
     :subject => "Re: [#{news.project.name}] #{l(:label_news)}: #{news.title}"
  end

  # Builds a tmail object used to email the recipients of the specified message that was posted.
  #
  # Example:
  #   message_posted(message) => tmail object
  #   Mailer.deliver_message_posted(message) => sends an email to the recipients
  def message_posted(message, recipient)
    redmine_headers 'Project' => message.project.identifier,
                    'Topic-Id' => (message.parent_id || message.id),
                    'Type' => "Forum"
    message_id message
    references message.parent unless message.parent.nil?
    recipients = message.recipients
    cc = ((message.root.watcher_recipients + message.board.watcher_recipients).uniq - recipients)
    @message = message
    @message_url = url_for({ :controller => 'messages', :action => 'show', :board_id => message.board, :id => message.root, :r => message, :anchor => "message-#{message.id}" })
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{message.board.project.name} - #{message.board.name} - msg#{message.root.id}] #{message.subject}"
  end

  # Builds a tmail object used to email the recipients of a project of the specified wiki content was added.
  #
  # Example:
  #   wiki_content_added(wiki_content) => tmail object
  #   Mailer.deliver_wiki_content_added(wiki_content) => sends an email to the project's recipients
  def wiki_content_added(wiki_content, recipient)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id,
                    'Type' => "Wiki"
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_added, :id => wiki_content.page.pretty_title)}"
  end

  # Builds a tmail object used to email the recipients of a project of the specified wiki content was updated.
  #
  # Example:
  #   wiki_content_updated(wiki_content) => tmail object
  #   Mailer.deliver_wiki_content_updated(wiki_content) => sends an email to the project's recipients
  def wiki_content_updated(wiki_content, recipient)
    redmine_headers 'Project' => wiki_content.project.identifier,
                    'Wiki-Page-Id' => wiki_content.page.id,
                    'Type' => "Wiki"
    message_id wiki_content
    recipients = wiki_content.recipients
    cc = wiki_content.page.wiki.watcher_recipients + wiki_content.page.watcher_recipients - recipients
    @wiki_content = wiki_content
    @wiki_content_url = url_for(:controller => 'wiki', :action => 'show',
                                      :project_id => wiki_content.project,
                                      :id => wiki_content.page.title)
    @wiki_diff_url = url_for(:controller => 'wiki', :action => 'diff',
                                   :project_id => wiki_content.project, :id => wiki_content.page.title,
                                   :version => wiki_content.version)
    mail :to => recipients,
      :cc => cc,
      :subject => "[#{wiki_content.project.name}] #{l(:mail_subject_wiki_content_updated, :id => wiki_content.page.pretty_title)}"
  end

  # Builds a tmail object used to email the specified user their account information.
  #
  # Example:
  #   account_information(user, password) => tmail object
  #   Mailer.deliver_account_information(user, password) => sends account information to the user
  def account_information(user, password)
    redmine_headers 'Type' => "Account"
    set_language_if_valid user.language
    @user = user
    @password = password
    @login_url = url_for(:controller => 'account', :action => 'login')
    mail :to => user.mail,
      :subject => l(:mail_subject_register, Setting.app_title)
  end

  # Builds a tmail object used to email all active administrators of an account activation request.
  #
  # Example:
  #   account_activation_request(user) => tmail object
  #   Mailer.deliver_account_activation_request(user)=> sends an email to all active administrators
  def account_activation_request(user)
    # Send the email to all active administrators
    recipients = User.active.find(:all, :conditions => {:admin => true}).collect { |u| u.mail }.compact
    @user = user
    @url = url_for(:controller => 'users', :action => 'index',
                         :status => User::STATUS_REGISTERED,
                         :sort_key => 'created_on', :sort_order => 'desc')
    mail :to => recipients,
      :subject => l(:mail_subject_account_activation_request, Setting.app_title)
  end

  # Builds a tmail object used to email the specified user that their account was activated by an administrator.
  #
  # Example:
  #   account_activated(user) => tmail object
  #   Mailer.deliver_account_activated(user) => sends an email to the registered user
  def account_activated(user)
    redmine_headers 'Type' => "Account"
    set_language_if_valid user.language
    @user = user
    @login_url = url_for(:controller => 'account', :action => 'login')
    mail :to => user.mail,
      :subject => l(:mail_subject_register, Setting.app_title)
  end

  def lost_password(token)
    redmine_headers 'Type' => "Account"
    set_language_if_valid(token.user.language)
    @token = token
    @url = url_for(:controller => 'account', :action => 'lost_password', :token => token.value)
    mail :to => token.user.mail,
      :subject => l(:mail_subject_lost_password, Setting.app_title)
  end

  def register(token)
    redmine_headers 'Type' => "Account"
    set_language_if_valid(token.user.language)
    @token = token
    @url = url_for(:controller => 'account', :action => 'activate', :token => token.value)
    mail :to => token.user.mail,
      :subject => l(:mail_subject_register, Setting.app_title)
  end

  def mail_handler_confirmation(object, user, email_subject)
    recipients = user.mail
    case
    when object.is_a?(Issue)
      project = object.project.name
      @url = url_for(:controller => 'issues', :action => 'show', :id => object.id)
    when object.is_a?(Journal)
      project = object.project.name
      @url = url_for(:controller => 'issues', :action => 'show', :id => object.issue.id)
    when object.class == Message
      project = object.project.name
      @url = url_for(object.event_url)
    else
      project = ''
      @url = ''
    end
    subject = "[#{project}] #{l(:label_mail_handler_confirmation, :subject => email_subject)}"
    mail :to => recipients, :subject => subject
  end

  def mail_handler_unauthorized_action(user, email_subject, options={})
    recipients = options[:to] || user.mail
    subject = l(:label_mail_handler_failure, :subject => email_subject)
    mail :to => recipients, :subject => subject
  end

  def mail_handler_missing_information(user, email_subject, error_message)
    recipients = user.mail
    subject = l(:label_mail_handler_failure, :subject => email_subject)
    @errors = error_message.to_s
    mail :to => recipients, :subject => subject
  end

  def test_email(user)
    redmine_headers 'Type' => "Test"
    set_language_if_valid(user.language)
    @url = url_for(:controller => 'welcome')
    mail :to => user.mail,
      :subject => 'ChiliProject test'
  end

  # Overrides default deliver! method to prevent from sending an email
  # with no recipient, cc or bcc
  def deliver!(mail = @mail)
    set_language_if_valid @initial_language
    return false if (recipients.nil? || recipients.empty?) &&
                    (cc.nil? || cc.empty?) &&
                    (bcc.nil? || bcc.empty?)


    # Log errors when raise_delivery_errors is set to false, Rails does not
    raise_errors = self.class.raise_delivery_errors
    self.class.raise_delivery_errors = true
    begin
      return super(mail)
    rescue Exception => e
      if raise_errors
        raise e
      elsif mylogger
        mylogger.error "The following error occured while sending email notification: \"#{e.message}\". Check your configuration in config/configuration.yml."
      end
    ensure
      self.class.raise_delivery_errors = raise_errors
    end
  end

  # Sends reminders to issue assignees
  # Available options:
  # * :days     => how many days in the future to remind about (defaults to 7)
  # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
  # * :project  => id or identifier of project to process (defaults to all projects)
  # * :users    => array of user ids who should be reminded
  def self.reminders(options={})
    days = options[:days] || 7
    project = options[:project] ? Project.find(options[:project]) : nil
    tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
    user_ids = options[:users]

    s = ARCondition.new ["#{IssueStatus.table_name}.is_closed = ? AND #{Issue.table_name}.due_date <= ?", false, days.day.from_now.to_date]
    s << "#{Issue.table_name}.assigned_to_id IS NOT NULL"
    s << ["#{Issue.table_name}.assigned_to_id IN (?)", user_ids] if user_ids.present?
    s << "#{Project.table_name}.status = #{Project::STATUS_ACTIVE}"
    s << "#{Issue.table_name}.project_id = #{project.id}" if project
    s << "#{Issue.table_name}.tracker_id = #{tracker.id}" if tracker

    issues_by_assignee = Issue.find(:all, :include => [:status, :assigned_to, :project, :tracker],
                                          :conditions => s.conditions
                                    ).group_by(&:assigned_to)
    issues_by_assignee.each do |assignee, issues|
      reminder(assignee, issues, days).deliver if assignee && assignee.active?
    end
  end

  # Activates/desactivates email deliveries during +block+
  def self.with_deliveries(enabled = true, &block)
    was_enabled = ActionMailer::Base.perform_deliveries
    ActionMailer::Base.perform_deliveries = !!enabled
    yield
  ensure
    ActionMailer::Base.perform_deliveries = was_enabled
  end

  # Sends emails synchronously in the given block
  def self.with_synched_deliveries(&block)
    saved_method = ActionMailer::Base.delivery_method
    if m = saved_method.to_s.match(%r{^async_(.+)$})
      ActionMailer::Base.delivery_method = m[1].to_sym
    end
    yield
  ensure
    ActionMailer::Base.delivery_method = saved_method
  end

  def mail(headers={})
    headers.merge! 'X-Mailer' => 'Redmine',
            'X-Redmine-Host' => Setting.host_name,
            'X-Redmine-Site' => Setting.app_title,
            'X-Auto-Response-Suppress' => 'OOF',
            'Auto-Submitted' => 'auto-generated',
            'From' => Setting.mail_from

    # Removes the author from the recipients and cc
    # if he doesn't want to receive notifications about what he does
    if @author && @author.logged? && @author.pref[:no_self_notified]
      headers[:to].delete(@author.mail) if headers[:to].is_a?(Array)
      headers[:cc].delete(@author.mail) if headers[:cc].is_a?(Array)
    end

    if @author && @author.logged?
      redmine_headers 'Sender' => @author.login
    end

    # Blind carbon copy recipients
    if Setting.bcc_recipients?
      headers[:bcc] = [headers[:to], headers[:cc]].flatten.uniq.reject(&:blank?)
      headers[:to] = nil
      headers[:cc] = nil
    end

    if @message_id_object
      headers[:message_id] = "<#{self.class.message_id_for(@message_id_object)}>"
    end
    if @references_objects
      headers[:references] = @references_objects.collect {|o| "<#{self.class.message_id_for(o)}>"}.join(' ')
    end

    super headers do |format|
      format.text
      format.html unless Setting.plain_text_mail?
    end

    set_language_if_valid @initial_language
  end

  def initialize(*args)
    @initial_language = current_language
    set_language_if_valid Setting.default_language
    super
  end
  
  def self.deliver_mail(mail)
    return false if mail.to.blank? && mail.cc.blank? && mail.bcc.blank?
    super
  end

  def self.method_missing(method, *args, &block)
    if m = method.to_s.match(%r{^deliver_(.+)$})
      ActiveSupport::Deprecation.warn "Mailer.deliver_#{m[1]}(*args) is deprecated. Use Mailer.#{m[1]}(*args).deliver instead."
      send(m[1], *args).deliver
    else
      super
    end
  end

  private

  # Appends a Redmine header field (name is prepended with 'X-Redmine-')
  def redmine_headers(h)
    h.each { |k,v| headers["X-Redmine-#{k}"] = v.to_s }
  end

  # Returns a predictable Message-Id for the given object
  def self.message_id_for(object)
    # id + timestamp should reduce the odds of a collision
    # as far as we don't send multiple emails for the same object
    timestamp = object.send(object.respond_to?(:created_on) ? :created_on : :updated_on)
    hash = "chiliproject.#{object.class.name.demodulize.underscore}-#{object.id}.#{timestamp.strftime("%Y%m%d%H%M%S")}"
    host = Setting.mail_from.to_s.gsub(%r{^.*@}, '')
    host = "#{::Socket.gethostname}.redmine" if host.empty?
    "#{hash}@#{host}"
  end

  def message_id(object)
    @message_id_object = object
  end

  def references(object)
    @references_objects ||= []
    @references_objects << object
  end

  def mylogger
    Rails.logger
  end
end
