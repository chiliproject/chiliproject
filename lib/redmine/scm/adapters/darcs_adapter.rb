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

require_dependency 'redmine/scm/adapters/abstract_adapter'
require 'rexml/document'

module Redmine
  module Scm
    module Adapters
      class DarcsAdapter < AbstractAdapter
        # Darcs executable name
        DARCS_BIN = Redmine::Configuration['scm_darcs_command'] || "darcs"

        class << self
          def client_command
            @@bin    ||= DARCS_BIN
          end

          def sq_bin
            @@sq_bin ||= shell_quote(DARCS_BIN)
          end

          def client_version
            @@client_version ||= (darcs_binary_version || [])
          end

          def client_available
            !client_version.empty?
          end

          def darcs_binary_version
            darcsversion = darcs_binary_version_from_command_line.dup
            if darcsversion.respond_to?(:force_encoding)
              darcsversion.force_encoding('ASCII-8BIT')
            end
            if m = darcsversion.match(%r{\A(.*?)((\d+\.)+\d+)})
              m[2].scan(%r{\d+}).collect(&:to_i)
            end
          end

          def darcs_binary_version_from_command_line
            shellout("#{sq_bin} --version"){ |io| io.read }.to_s
          end
        end

        def initialize(url, root_url=nil, login=nil, password=nil,
                       path_encoding=nil)
          @url = url
          @root_url = url
        end

        def supports_cat?
          # cat supported in darcs 2.0.0 and higher
          self.class.client_version_above?([2, 0, 0])
        end

        # Get info about the darcs repository
        def info
          rev = revisions(nil,nil,nil,{:limit => 1})
          rev ? Info.new({:root_url => @url, :lastrev => rev.last}) : nil
        end

        # Returns an Entries collection
        # or nil if the given path doesn't exist in the repository
        def entries(path=nil, identifier=nil)
          path_prefix = (path.blank? ? '' : "#{path}/")
          if path.blank?
            path = ( self.class.client_version_above?([2, 2, 0]) ? @url : '.' )
          end
          cmd_args = %W|annotate --repodir #{shell_quote @url} --xml-output|
          cmd_args << " --match #{shell_quote("hash #{identifier}")}" if identifier
          cmd_args << " #{shell_quote path}"
          scm_cmd(cmd_args) do |io|
            entries = Entries.new
            doc = REXML::Document.new(io)
            if doc.root.name == 'directory'
              doc.elements.each('directory/*') do |element|
                next unless ['file', 'directory'].include? element.name
                entries << entry_from_xml(element, path_prefix)
              end
            elsif doc.root.name == 'file'
              entries << entry_from_xml(doc.root, path_prefix)
            end
            entries.compact.sort_by_name
          end
        end

        def revisions(path=nil, identifier_from=nil, identifier_to=nil, options={})
          path = '.' if path.blank?
          cmd_args = %W|changes --repodir #{shell_quote @url} --xml-output|
          cmd_args << " --from-match #{shell_quote("hash #{identifier_from}")}" if identifier_from
          cmd_args << " --last #{options[:limit].to_i}" if options[:limit]
          scm_cmd(cmd_args) do |io|
            revisions = Revisions.new
            doc = REXML::Document.new(io)
            doc.elements.each("changelog/patch") do |patch|
              message = patch.elements['name'].text
              message << "\n" + patch.elements['comment'].text.gsub(/\*\*\*END OF DESCRIPTION\*\*\*.*\z/m, '') if patch.elements['comment']
              revisions << Revision.new({:identifier => nil,
                            :author => patch.attributes['author'],
                            :scmid => patch.attributes['hash'],
                            :time => Time.parse(patch.attributes['local_date']),
                            :message => message,
                            :paths => (options[:with_path] ? get_paths_for_patch(patch.attributes['hash']) : nil)
                          })
            end
            revisions
          end
        end

        def diff(path, identifier_from, identifier_to=nil)
          path = '*' if path.blank?
          cmd_args = %W|diff --repodir #{shell_quote @url}|
          if identifier_to.nil?
            cmd_args << "--match #{shell_quote("hash #{identifier_from}")}"
          else
            cmd_args << "--to-match #{shell_quote("hash #{identifier_from}")}"
            cmd_args << "--from-match #{shell_quote("hash #{identifier_to}")}"
          end
          cmd_args << "-u #{shell_quote path}"
          scm_cmd(cmd_args) do |io|
            diff = []
            io.each_line { |line| diff << line }
            diff
          end
        end

        def cat(path, identifier=nil)
          cmd_args = %W|show content --repodir #{shell_quote @url}|
          cmd_args << "--match #{shell_quote("hash #{identifier}")}" if identifier
          cmd_args << shell_quote(path)
          scm_cmd(cmd_args) do |io|
            io.binmode
            io.read
          end
        end

        def save_entry_in_file(f, path, identifier)
          cmd_args = %W|show content --repodir #{shell_quote @url}|
          cmd_args << "--match #{shell_quote("hash #{identifier}")}" if identifier
          cmd_args << shell_quote(path)
          scm_cmd(cmd_args, f.path)
        end

        private

        # Returns an Entry from the given XML element
        # or nil if the entry was deleted
        def entry_from_xml(element, path_prefix)
          modified_element = element.elements['modified']
          if modified_element.elements['modified_how'].text.match(/removed/)
            return nil
          end

          Entry.new({:name => element.attributes['name'],
                     :path => path_prefix + element.attributes['name'],
                     :kind => element.name == 'file' ? 'file' : 'dir',
                     :size => nil,
                     :lastrev => Revision.new({
                       :identifier => nil,
                       :scmid => modified_element.elements['patch'].attributes['hash']
                       })
                     })
        end

        def get_paths_for_patch(hash)
          paths = get_paths_for_patch_raw(hash)
          if self.class.client_version_above?([2, 4])
            orig_paths = paths
            paths = []
            add_paths = []
            add_paths_name = []
            mod_paths = []
            other_paths = []
            orig_paths.each do |path|
              if path[:action] == 'A'
                add_paths << path
                add_paths_name << path[:path]
              elsif path[:action] == 'M'
                mod_paths << path
              else
                other_paths << path
              end
            end
            add_paths_name.each do |add_path|
              mod_paths.delete_if { |m| m[:path] == add_path }
            end
            paths.concat add_paths
            paths.concat mod_paths
            paths.concat other_paths
          end
          paths
        end

        # Retrieve changed paths for a single patch
        def get_paths_for_patch_raw(hash)
          cmd_args = %W|annotate --repodir #{shell_quote @url} --summary --xml-output --match #{shell_quote("hash #{hash}")}|
          scm_cmd(cmd_args) do |io|
            paths = []
            # Darcs xml output has multiple root elements in this case (tested with darcs 1.0.7)
            # A root element is added so that REXML doesn't raise an error
            doc = REXML::Document.new("<fake_root>" + io.read + "</fake_root>")
            doc.elements.each('fake_root/summary/*') do |modif|
              paths << {:action => modif.name[0,1].upcase,
                        :path => "/" + modif.text.chomp.gsub(/^\s*/, '')
                       }
            end
            paths
          end || [] # this method should not return nil
        end
      end
    end
  end
end
