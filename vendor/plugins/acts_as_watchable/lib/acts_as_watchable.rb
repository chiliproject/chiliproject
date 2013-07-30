#-- encoding: UTF-8
# ActsAsWatchable
module Redmine
  module Acts
    module Watchable
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def acts_as_watchable(options = {})
          return if self.included_modules.include?(Redmine::Acts::Watchable::InstanceMethods)
          send :include, Redmine::Acts::Watchable::InstanceMethods

          class_eval do
            has_many :watchers, :as => :watchable, :dependent => :delete_all
            has_many :watcher_users, :through => :watchers, :source => :user, :validate => false

            attr_protected :watcher_ids, :watcher_user_ids
          end
        end

        def watched_by(user)
          join(:watchers).where(:watchers => {:user_id => user})
        end
      end

      module InstanceMethods
        def self.included(base)
          base.extend ClassMethods
        end

        # Returns an array of users that are proposed as watchers
        def addable_watcher_users
          self.project.users.sort - self.watcher_users
        end

        # Adds user as a watcher
        def add_watcher(user)
          self.watchers << Watcher.new(:user => user)
        end

        # Removes user from the watchers list
        def remove_watcher(user)
          return nil unless user && user.is_a?(Principal)
          Watcher.delete_all "watchable_type = '#{self.class}' AND watchable_id = #{self.id} AND user_id = #{user.id}"
        end

        # Adds/removes watcher
        def set_watcher(user, watching=true)
          watching ? add_watcher(user) : remove_watcher(user)
        end

        # Returns true if object is watched by +user+
        def watched_by?(user)
          !!(user && self.watcher_user_ids.detect {|uid| uid == user.id })
        end

        # Returns an array of watchers' email addresses
        def watcher_recipients
          notified = watcher_users.active
          notified.reject! {|user| user.mail_notification == 'none'}

          if respond_to?(:visible?)
            notified.reject! {|user| !visible?(user)}
          end

          notified.collect {|w|
            if w.respond_to?(:mail) && w.mail.present? # Single mail
              w.mail
            elsif w.respond_to?(:mails) && w.mails.present? # Multiple mail
              w.mails
            end
          }.flatten.compact
        end

        module ClassMethods; end
      end
    end
  end
end
