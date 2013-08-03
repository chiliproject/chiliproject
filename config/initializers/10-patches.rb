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

require 'active_record'

module ActiveRecord
  class Base
    include Redmine::I18n

    # Translate attribute names for validation errors display
    def self.human_attribute_name(attr, *args)
      l("field_#{attr.to_s.gsub(/_id$/, '')}", :default => attr)
    end
  end
end

module ActiveRecord
  class Errors
    def full_messages(options = {})
      full_messages = []

      @errors.each_key do |attr|
        @errors[attr].each do |message|
          next unless message

          if attr == "base"
            full_messages << message
          elsif attr == "custom_values"
            # Replace the generic "custom values is invalid"
            # with the errors on custom values
            @base.custom_values.each do |value|
              value.errors.each do |attr, msg|
                full_messages << value.custom_field.name + ' ' + msg
              end
            end
          else
            attr_name = @base.class.human_attribute_name(attr)
            full_messages << attr_name + ' ' + message.to_s
          end
        end
      end
      full_messages
    end
  end
end

module ActionView
  module Helpers
    module DateHelper
      # distance_of_time_in_words breaks when difference is greater than 30 years
      def distance_of_date_in_words(from_date, to_date = 0, options = {})
        from_date = from_date.to_date if from_date.respond_to?(:to_date)
        to_date = to_date.to_date if to_date.respond_to?(:to_date)
        distance_in_days = (to_date - from_date).abs

        I18n.with_options :locale => options[:locale], :scope => :'datetime.distance_in_words' do |locale|
          case distance_in_days
            when 0..60     then locale.t :x_days,             :count => distance_in_days.round
            when 61..720   then locale.t :about_x_months,     :count => (distance_in_days / 30).round
            else                locale.t :over_x_years,       :count => (distance_in_days / 365).floor
          end
        end
      end
    end

    module FormHelper
      # Returns an input tag of the "date" type tailored for accessing a specified attribute (identified by +method+) on an object
      # assigned to the template (identified by +object+). Additional options on the input tag can be passed as a
      # hash with +options+. These options will be tagged onto the HTML as an HTML element attribute as in the example
      # shown.
      #
      # ==== Examples
      #   date_field(:user, :birthday, :size => 20)
      #   # => <input type="date" id="user_birthday" name="user[birthday]" size="20" value="#{@user.birthday}" />
      #
      #   date_field(:user, :birthday, :class => "create_input")
      #   # => <input type="date" id="user_birthday" name="user[birthday]" value="#{@user.birthday}" class="create_input" />
      #
      # NOTE: This will be part of rails 4.0, the monkey patch can be removed by then.
      def date_field(object_name, method, options = {})
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("date", options)
      end
    end

    # As ActionPacks metaprogramming will already have happened when we're here,
    # we have to tell the FormBuilder about the above date_field ourselvse
    #
    # NOTE: This can be remove when the above ActionView::Helpers::FormHelper#date_field is removed
    class FormBuilder
      self.field_helpers << "date_field"

      def date_field(method, options = {})
        @template.date_field(@object_name, method, objectify_options(options))
      end
    end

    module FormTagHelper
      # Creates a date form input field.
      #
      # ==== Options
      # * Creates standard HTML attributes for the tag.
      #
      # ==== Examples
      #   date_field_tag 'meeting_date'
      #   # => <input id="meeting_date" name="meeting_date" type="date" />
      #
      # NOTE: This will be part of rails 4.0, the monkey patch can be removed by then.
      def date_field_tag(name, value = nil, options = {})
        text_field_tag(name, value, options.stringify_keys.update("type" => "date"))
      end
    end
  end
end

ActionView::Base.field_error_proc = Proc.new{ |html_tag, instance| html_tag || ''.html_safe }

require 'mail'

module DeliveryMethods
  class AsyncSMTP < ::Mail::SMTP
    def deliver!(*args)
      Thread.start do
        super *args
      end
    end
  end

  class AsyncSendmail < ::Mail::Sendmail
    def deliver!(*args)
      Thread.start do
        super *args
      end
    end
  end

  class TmpFile
    def initialize(*args); end

    def deliver!(mail)
      dest_dir = File.join(Rails.root, 'tmp', 'emails')
      Dir.mkdir(dest_dir) unless File.directory?(dest_dir)
      File.open(File.join(dest_dir, mail.message_id.gsub(/[<>]/, '') + '.eml'), 'wb') {|f| f.write(mail.encoded) }
    end
  end
end

ActionMailer::Base.add_delivery_method :async_smtp, DeliveryMethods::AsyncSMTP
ActionMailer::Base.add_delivery_method :async_sendmail, DeliveryMethods::AsyncSendmail
ActionMailer::Base.add_delivery_method :tmp_file, DeliveryMethods::TmpFile

# Changes how sent emails are logged
# Rails doesn't log cc and bcc which is misleading when using bcc only (#12090)
module ActionMailer
  class LogSubscriber < ActiveSupport::LogSubscriber
    def deliver(event)
      recipients = [:to, :cc, :bcc].inject("") do |s, header|
        r = Array.wrap(event.payload[header])
        if r.any?
          s << "\n  #{header}: #{r.join(', ')}"
        end
        s
      end
      info("\nSent email \"#{event.payload[:subject]}\" (%1.fms)#{recipients}" % event.duration)
      debug(event.payload[:mail])
    end
  end
end

module ActionController
  module MimeResponds
    class Collector
      def api(&block)
        any(:xml, :json, &block)
      end
    end
  end
end

module ActionController
  class Base
    # Displays an explicit message instead of a NoMethodError exception
    # when trying to start Redmine with an old session_store.rb
    # TODO: remove it in a later version
    def self.session=(*args)
      $stderr.puts "Please remove config/initializers/session_store.rb and run `rake generate_secret_token`.\n" +
        "Setting the session secret with ActionController.session= is no longer supported in Rails 3."
      exit 1
    end
  end
end
