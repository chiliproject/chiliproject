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
require 'uri'

module Redmine
  module Scm
    module Adapters
      class SubversionAdapter < AbstractAdapter

        # SVN executable name
        SVN_BIN = Redmine::Configuration['scm_subversion_command'] || "svn"

        class << self
          def client_command
            @@bin    ||= SVN_BIN
          end

          def sq_bin
            @@sq_bin ||= shell_quote(SVN_BIN)
          end

          def client_version
            @@client_version ||= (svn_binary_version || [])
          end

          def client_available
            !client_version.empty?
          end

          def svn_binary_version
            scm_version = scm_version_from_command_line.dup
            if scm_version.respond_to?(:force_encoding)
              scm_version.force_encoding('ASCII-8BIT')
            end
            if m = scm_version.match(%r{\A(.*?)((\d+\.)+\d+)})
              m[2].scan(%r{\d+}).collect(&:to_i)
            end
          end

          def scm_version_from_command_line
            shellout("#{sq_bin} --version"){ |io| io.read }.to_s
          end
        end

        # Get info about the svn repository
        def info
          cmd_args = ['info','--xml', target, credentials_string]
          scm_cmd(cmd_args) do |io|
            output = io.read
            if output.respond_to?(:force_encoding)
              output.force_encoding('UTF-8')
            end
            doc = ActiveSupport::XmlMini.parse(output)
            #root_url = doc.elements["info/entry/repository/root"].text
            Info.new({
              :root_url => doc['info']['entry']['repository']['root']['__content__'],
              :lastrev => Revision.new({
                :identifier => doc['info']['entry']['commit']['revision'],
                :time => Time.parse(doc['info']['entry']['commit']['date']['__content__']).localtime,
                :author => (doc['info']['entry']['commit']['author'] ? doc['info']['entry']['commit']['author']['__content__'] : "")
              })
            })
          end
        end

        # Returns an Entries collection
        # or nil if the given path doesn't exist in the repository
        def entries(path=nil, identifier=nil)
          path ||= ''
          identifier = initialize_identifier(identifier)
          entries = Entries.new
          cmd_args = ['list', '--xml', "#{target(path)}@#{identifier}", credentials_string]
          scm_cmd(cmd_args) do |io|
            output = io.read
            if output.respond_to?(:force_encoding)
              output.force_encoding('UTF-8')
            end
            doc = ActiveSupport::XmlMini.parse(output)
            each_xml_element(doc['lists']['list'], 'entry') do |entry|
              commit = entry['commit']
              commit_date = commit['date']
              # Skip directory if there is no commit date (usually that
              # means that we don't have read access to it)
              next if entry['kind'] == 'dir' && commit_date.nil?
              name = entry['name']['__content__']
              entries << Entry.new({:name => URI.unescape(name),
                          :path => ((path.empty? ? "" : "#{path}/") + name),
                          :kind => entry['kind'],
                          :size => ((s = entry['size']) ? s['__content__'].to_i : nil),
                          :lastrev => Revision.new({
                            :identifier => commit['revision'],
                            :time => Time.parse(commit_date['__content__'].to_s).localtime,
                            :author => ((a = commit['author']) ? a['__content__'] : nil)
                            })
                          })
            end
            logger.debug("Found #{entries.size} entries in the repository for #{target(path)}") if logger && logger.debug?
            entries.sort_by_name
          end
        end

        def properties(path, identifier=nil)
          # proplist xml output supported in svn 1.5.0 and higher
          return nil unless self.class.client_version_above?([1, 5, 0])

          identifier = initialize_identifier(identifier)
          cmd_args = ['proplist', '--verbose', '--xml', "#{target(path)}@#{identifier}", credentials_string]
          properties = {}
          scm_cmd(cmd_args) do |io|
            output = io.read
            if output.respond_to?(:force_encoding)
              output.force_encoding('UTF-8')
            end
            doc = ActiveSupport::XmlMini.parse(output)
            each_xml_element(doc['properties']['target'], 'property') do |property|
              properties[ property['name'] ] = property['__content__'].to_s
            end
            properties
          end
        end

        def revisions(path=nil, identifier_from=nil, identifier_to=nil, options={})
          path ||= ''
          identifier_from = initialize_identifier(identifier_from)
          identifier_to   = initialize_identifier(identifier_to, 1)

          cmd_args = ['log', '--xml', '-r', "#{identifier_from}:#{identifier_to}", credentials_string]
          cmd_args << " --verbose " if  options[:with_paths]
          cmd_args << " --limit #{options[:limit].to_i}" if options[:limit]
          cmd_args << target(path)

          revisions = Revisions.new

          scm_cmd(cmd_args) do |io|
            output = io.read
            if output.respond_to?(:force_encoding)
              output.force_encoding('UTF-8')
            end
            doc = ActiveSupport::XmlMini.parse(output)
            each_xml_element(doc['log'], 'logentry') do |logentry|
              paths = []

              if logentry['paths'] && logentry['paths']['path']
                each_xml_element(logentry['paths'], 'path') do |path|
                  paths << {:action => path['action'],
                            :path => path['__content__'],
                            :from_path => path['copyfrom-path'],
                            :from_revision => path['copyfrom-rev']
                            }
                end
              end
              paths.sort! { |x,y| x[:path] <=> y[:path] }

              revisions << Revision.new({:identifier => logentry['revision'],
                            :author => (logentry['author'] ? logentry['author']['__content__'] : ""),
                            :time => Time.parse(logentry['date']['__content__'].to_s).localtime,
                            :message => logentry['msg']['__content__'],
                            :paths => paths
                          })
            end
            revisions
          end
        end

        def diff(path, identifier_from, identifier_to=nil, type="inline")
          path ||= ''

          identifier_from = initialize_identifier(identifier_from, '')
          identifier_to = initialize_identifier(identifier_to, identifier_from.to_i - 1)

          cmd_args = ["diff -r",
                      "#{identifier_to}:#{identifier_from}",
                      "#{target(path)}@#{identifier_from}",
                      credentials_string]
          diff = []
          scm_cmd(cmd_args) do |io|
            io.each_line do |line|
              diff << line
            end
            diff
          end
        end

        def cat(path, identifier=nil)
          identifier = initialize_identifier(identifier)

          cmd_args = ['cat', "#{target(path)}@#{identifier}", credentials_string]
          scm_cmd(cmd_args) do |io|
            io.binmode
            io.read
          end
        end

        def save_entry_in_file(f, path, identifier)
          identifier = initialize_identifier(identifier)
          cmd_args = ['cat', "#{target(path)}@#{identifier}", credentials_string]
          scm_cmd(cmd_args, f.path)
        end

        def annotate(path, identifier=nil)
          identifier = initialize_identifier(identifier)
          cmd_args = ['blame', "#{target(path)}@#{identifier}", credentials_string]
          blame = Annotate.new
          scm_cmd(cmd_args) do |io|
            io.each_line do |line|
              next unless line =~ %r{^\s*(\d+)\s*(\S+)\s(.*)$}
              blame.add_line($3.rstrip, Revision.new(:identifier => $1.to_i, :author => $2.strip))
            end
            blame
          end
        end

        private

        def initialize_identifier(identifier, default="HEAD")
          (identifier && identifier.to_i > 0) ? identifier.to_i : default
        end

        def credentials_string
          str = ''
          str << " --username #{shell_quote(@login)}" unless @login.blank?
          str << " --password #{shell_quote(@password)}" unless @login.blank? || @password.blank?
          str << " --no-auth-cache --non-interactive"
          str
        end

        # Helper that iterates over the child elements of a xml node
        # MiniXml returns a hash when a single child is found or an array of hashes for multiple children
        def each_xml_element(node, name)
          if node && node[name]
            if node[name].is_a?(Hash)
              yield node[name]
            else
              node[name].each do |element|
                yield element
              end
            end
          end
        end

        def target(path = '')
          base = path.match(/^\//) ? root_url : url
          uri = "#{base}/#{path}"
          uri = URI.escape(URI.escape(uri), '[]')
          shell_quote(uri.gsub(/[?<>\*]/, ''))
        end
      end
    end
  end
end
