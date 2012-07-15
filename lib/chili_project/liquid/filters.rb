#-- encoding: UTF-8
#-- copyright
# ChiliProject is a project management system.
#
# Copyright (C) 2010-2012 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module ChiliProject
  module Liquid
    module OverriddenFilters
      # These filters are defined in liquid core but are overwritten here
      # to improve on their implementation

      # Split input string into an array of substrings separated by given pattern.
      # Default to whitespace
      def split(input, pattern=nil)
        input.split(pattern)
      end

      def strip_newlines(input)
        input.to_s.gsub(/\r?\n/, '')
      end

      # Add <br /> tags in front of all newlines in input string
      def newline_to_br(input)
        input.to_s.gsub(/(\r?\n)/, "<br />\1")
      end

      # Use the block systax for sub and gsub to prevent interpretation of
      # backreferences
      # See https://gist.github.com/1491437
      def replace(input, string, replacement = '')
        input.to_s.gsub(string){replacement}
      end

      # Replace the first occurrences of a string with another
      def replace_first(input, string, replacement = '')
        input.to_s.sub(string){replacement}
      end

      # Get the first element(s) of the passed in array
      # Example:
      #    {{ product.images | first | to_img }}
      def first(array, count=nil)
        return array.first if count.nil? && array.respond_to?(:first)
        if array.respond_to?(:[])
          count.to_i > 0 ? array[0..count.to_i-1] : []
        end
      end

      # Get the last element(s) of the passed in array
      # Example:
      #    {{ product.images | last | to_img }}
      def last(array, count=nil)
        array.last if count=nil? && array.respond_to?(:last)
        if array.respond_to?(:[])
          count.to_i > 0 ? array[(count.to_i * -1)..-1] : []
        end
      end

      def date(input, format=nil)
        if format.nil?
          return "" unless input
          if Setting.date_format.blank?
            input = super(input, '%Y-%m-%d')
            return ::I18n.l(input.to_date) if input.respond_to?(:to_date)
            input # default return value
          else
            super(input, Setting.date_format)
          end
        else
          super
        end
      end
    end

    module Filters
      def default(input, default)
        input.to_s.strip.present? ? input : default
      end

      def strip(input)
        input.to_s.strip
      end

      def to_list(array, header_or_depth = nil)
        result = []
        if header_or_depth.is_a?(String)
          result << "\np. #{header_or_depth}\n"
          depth = 1
        else
          if header_or_depth.respond_to?(:to_i)
            depth = [1, header_or_depth.to_i].max
          else
            depth = 1
          end
        end

        result += (array || []).collect{|elm| "#{"*" * depth.to_i } #{elm.to_s}"}
        result.join("\n")
      end
    end

    Template.register_filter(OverriddenFilters)
    Template.register_filter(Filters)
  end
end
