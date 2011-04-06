# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module Redmine
  module Themes

    # Return an array of installed themes
    def self.themes
      @@installed_themes ||= scan_themes
    end

    # Rescan themes directory
    def self.rescan
      @@installed_themes = scan_themes
    end

    # Return theme for given id, or nil if it's not found
    def self.theme(id, options={})
      return nil if id.blank?

      found = themes.find {|t| t.id == id}
      if found.nil? && options[:rescan] != false
        rescan
        found = theme(id, :rescan => false)
      end
      found
    end

    # Class used to represent a theme
    class Theme
      attr_reader :path, :name, :dir

      def initialize(path)
        @path = path
        @dir = File.basename(path)
        @name = @dir.humanize
        @stylesheets = nil
        @javascripts = nil
      end

      # Directory name used as the theme id
      def id; dir end

      def ==(theme)
        theme.is_a?(Theme) && theme.dir == dir
      end

      def <=>(theme)
        name <=> theme.name
      end

      def stylesheets
        @stylesheets ||= assets("stylesheets", "css")
      end

      def javascripts
        @javascripts ||= assets("javascripts", "js")
      end

      def stylesheet_path(source)
        "/themes/#{dir}/stylesheets/#{source}"
      end

      def javascript_path(source)
        "/themes/#{dir}/javascripts/#{source}"
      end

      private

      def assets(dir, ext)
        Dir.glob("#{path}/#{dir}/*.#{ext}").collect {|f| File.basename(f).gsub(/\.#{ext}$/, '')}
      end
    end

    private

    def self.scan_themes
      theme_paths.inject([]) do |themes, path|
        dirs = Dir.glob(File.join(path, '*')).select do |f|
          # A theme should at least override application.css
          File.directory?(f) && File.exist?("#{f}/stylesheets/application.css")
        end
        themes += dirs.collect { |dir| Theme.new(dir) }
      end.sort
    end

    ChiliProject.config.defaults['themes_storage_path'] = ["#{Rails.public_path}/themes"]
    def self.theme_paths
      paths = ChiliProject.config['themes_storage_path']
      paths = [paths] unless paths.is_a?(Array)
      paths.flatten!; paths.compact!

      paths.collect { |p| File.expand_path(p, Rails.root) }
    end
  end
end

module ApplicationHelper
  def current_theme
    unless instance_variable_defined?(:@current_theme)
      @current_theme = Redmine::Themes.theme(Setting.ui_theme)
    end
    @current_theme
  end

  def stylesheet_path(source)
    if current_theme && current_theme.stylesheets.include?(source)
      super current_theme.stylesheet_path(source)
    else
      super
    end
  end

  def path_to_stylesheet(source)
    stylesheet_path source
  end

  # Returns the header tags for the current theme
  def heads_for_theme
    if current_theme && current_theme.javascripts.include?('theme')
      javascript_include_tag current_theme.javascript_path('theme')
    end
  end
end
