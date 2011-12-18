#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2011 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module Redmine
  module WikiFormatting
    class StaleSectionError < Exception; end

    @@formatters = {}

    class << self
      def map
        yield self
      end

      def register(name, formatter, helper)
        raise ArgumentError, "format name '#{name}' is already taken" if @@formatters[name.to_s]
        @@formatters[name.to_s] = {:formatter => formatter, :helper => helper}
      end

      def formatter
        formatter_for(Setting.text_formatting)
      end

      def formatter_for(name)
        entry = @@formatters[name.to_s]
        (entry && entry[:formatter]) || Redmine::WikiFormatting::NullFormatter::Formatter
      end

      def helper_for(name)
        entry = @@formatters[name.to_s]
        (entry && entry[:helper]) || Redmine::WikiFormatting::NullFormatter::Helper
      end

      def format_names
        @@formatters.keys.map
      end

      def to_html(format, text, options = {})
        text = if Setting.cache_formatted_text? && text.size > 2.kilobyte && cache_store && cache_key = cache_key_for(format, options[:object], options[:attribute])
          # Text retrieved from the cache store may be frozen
          # We need to dup it so we can do in-place substitutions with gsub!
          cache_store.fetch cache_key do
            formatter_for(format).new(text).to_html
          end.dup
        else
          formatter_for(format).new(text).to_html
        end
        text
      end

      # Returns true if the text formatter supports single section edit
      def supports_section_edit?
        (formatter.instance_methods & ['update_section', :update_section]).any?
      end

      # Returns a cache key for the given text +format+, +object+ and +attribute+ or nil if no caching should be done
      def cache_key_for(format, object, attribute)
        if object && attribute && !object.new_record? && object.respond_to?(:updated_on) && !format.blank?
          "formatted_text/#{format}/#{object.class.model_name.cache_key}/#{object.id}-#{attribute}-#{object.updated_on.to_s(:number)}"
        end
      end

      # Returns the cache store used to cache HTML output
      def cache_store
        ActionController::Base.cache_store
      end
    end
  end
end
