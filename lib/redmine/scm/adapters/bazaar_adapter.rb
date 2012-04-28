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

module Redmine
  module Scm
    module Adapters
      class BazaarAdapter < AbstractAdapter

        # Bazaar executable name
        BZR_BIN = Redmine::Configuration['scm_bazaar_command'] || "bzr"

        class << self
          def client_command
            @@bin    ||= BZR_BIN
          end

          def sq_bin
            @@sq_bin ||= shell_quote(BZR_BIN)
          end

          def client_version
            @@client_version ||= (scm_command_version || [])
          end

          def client_available
            !client_version.empty?
          end

          def scm_command_version
            scm_version = scm_version_from_command_line.dup
            if scm_version.respond_to?(:force_encoding)
              scm_version.force_encoding('ASCII-8BIT')
            end
            if m = scm_version.match(%r{\A(.*?)((\d+\.)+\d+)})
              m[2].scan(%r{\d+}).collect(&:to_i)
            end
          end

          def scm_version_from_command_line
            shellout("--version"){ |io| io.read }.to_s
          end
        end

        # Get info about the repository
        def info
          cmd_args = ['revno', target('')]
          scm_cmd cmd_args do |io|
            if io.read =~ %r{^(\d+)\r?$}
              Info.new({
                :root_url => url,
                :lastrev => Revision.new({ :identifier => $1})
              })
            end
          end
        end

        # Returns an Entries collection
        # or nil if the given path doesn't exist in the repository
        def entries(path=nil, identifier=nil)
          path ||= ''
          identifier = initialize_identifier(identifier, -1)
          cmd_args = %W|ls -v --show-ids -r#{identifier.to_i} #{target(path)}|
          scm_cmd cmd_args do |io|
            entries = Entries.new
            prefix = "#{url}/#{path}".gsub('\\', '/')
            logger.debug "PREFIX: #{prefix}" if logger && logger.debug?
            re = %r{^V\s+(#{Regexp.escape(prefix)})?(\/?)([^\/]+)(\/?)\s+(\S+)\r?$}
            io.each_line do |line|
              next unless line =~ re
              entries << Entry.new({:name => $3.strip,
                                    :path => ((path.empty? ? "" : "#{path}/") + $3.strip),
                                    :kind => ($4.blank? ? 'file' : 'dir'),
                                    :size => nil,
                                    :lastrev => Revision.new(:revision => $5.strip)
                                  })
            end
            logger.debug("Found #{entries.size} entries in the repository for #{target(path)}") if logger && logger.debug?
            entries.sort_by_name
          end
        end

        def revisions(path=nil, identifier_from=nil, identifier_to=nil, options={})
          path ||= ''
          identifier_from = initialize_identifier(identifier_from, 'last:1')
          identifier_to =   initialize_identifier(identifier_to,   1)
          cmd_args = %W|log -v --show-ids -r#{identifier_to}..#{identifier_from} #{target(path)}|
          scm_cmd cmd_args do |io|
            revisions = Revisions.new
            revision = nil
            parsing = nil
            io.each_line do |line|
              if line =~ /^----/
                revisions << revision if revision
                revision = Revision.new(:paths => [], :message => '')
                parsing = nil
              else
                next unless revision

                if line =~ /^revno: (\d+)($|\s\[merge\]$)/
                  revision.identifier = $1.to_i
                elsif line =~ /^committer: (.+)$/
                  revision.author = $1.strip
                elsif line =~ /^revision-id:(.+)$/
                  revision.scmid = $1.strip
                elsif line =~ /^timestamp: (.+)$/
                  revision.time = Time.parse($1).localtime
                elsif line =~ /^    -----/
                  # partial revisions
                  parsing = nil unless parsing == 'message'
                elsif line =~ /^(message|added|modified|removed|renamed):/
                  parsing = $1
                elsif line =~ /^  (.*)$/
                  if parsing == 'message'
                    revision.message << "#{$1}\n"
                  else
                    if $1 =~ /^(.*)\s+(\S+)$/
                      path = $1.strip
                      revid = $2
                      case parsing
                      when 'added'
                        revision.paths << {:action => 'A', :path => "/#{path}", :revision => revid}
                      when 'modified'
                        revision.paths << {:action => 'M', :path => "/#{path}", :revision => revid}
                      when 'removed'
                        revision.paths << {:action => 'D', :path => "/#{path}", :revision => revid}
                      when 'renamed'
                        new_path = path.split('=>').last
                        revision.paths << {:action => 'M', :path => "/#{new_path.strip}", :revision => revid} if new_path
                      end
                    end
                  end
                else
                  parsing = nil
                end
              end
            end
            revisions << revision if revision
            revisions
          end
        end

        def diff(path, identifier_from, identifier_to=nil)
          path ||= ''
          identifier_from = initialize_identifier(identifier_from)
          identifier_to =   initialize_identifier(identifier_to, identifier_from.to_i - 1)
          cmd_args = %W|diff -r#{identifier_to}..#{identifier_from} #{target(path)}|
          diff = []
          scm_cmd cmd_args do |io|
            io.each_line{ |ln| diff << ln }
          end
          diff # this method must not return nil
        end

        def cat(path, identifier=nil)
          identifier = initialize_identifier(identifier)
          cmd_args = ["cat", target(path)]
          cmd_args << "-r#{identifier}" if identifier
          scm_cmd(cmd_args) do |io|
            io.binmode
            io.read
          end
        end

        def save_entry_in_file(f, path, identifier)
          identifier = initialize_identifier(identifier)
          cmd_args = ["cat", target(path)]
          cmd_args << "-r#{identifier}" if identifier
          scm_cmd(cmd_args, f.path)
        end

        def annotate(path, identifier=nil)
          identifier = initialize_identifier(identifier)
          cmd_args = %W|annotate --all|
          cmd_args << "-r#{identifier}" if identifier
          cmd_args << target(path)
          scm_cmd(cmd_args) do |io|
            blame = Annotate.new
            author = nil
            identifier = nil
            io.each_line do |line|
              next unless line =~ %r{^(\d+) ([^|]+)\| (.*)$}
              blame.add_line($3.rstrip, Revision.new(:identifier => $1.to_i, :author => $2.strip))
            end
            blame
          end
        end

        private

        def initialize_identifier(identifier, default=nil)
          return identifier.to_i if identifier && identifier.to_i > 0
          default
        end

      end
    end
  end
end
