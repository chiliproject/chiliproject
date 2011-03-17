# redMine - project management software
# Copyright (C) 2006-2007  Jean-Philippe Lang
# Copyright (C) 2007  Patrick Aljord patcito@ŋmail.com
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

require 'redmine/scm/adapters/git_adapter'

class Repository::Git < Repository
  attr_protected :root_url
  validates_presence_of :url

  def scm_adapter
    Redmine::Scm::Adapters::GitAdapter
  end
  
  def self.scm_name
    'Git'
  end

  # Returns the identifier for the given git changeset
  def self.changeset_identifier(changeset)
    changeset.scmid
  end

  # Returns the readable identifier for the given git changeset
  def self.format_changeset_identifier(changeset)
    changeset.revision[0, 8]
  end

  def branches
    scm.branches
  end

  def tags
    scm.tags
  end

  # With SCM's that have a sequential commit numbering, redmine is able to be
  # clever and only fetch changesets going forward from the most recent one
  # it knows about.  However, with git, you never know if people have merged
  # commits into the middle of the repository history, so we should parse
  # the entire log. But now we store last branches heads in scm_metadata serialized
  # field.
  # But if somebody rewrite some branch in git this could cause unpredictable problems.
  # The repository can still be fully reloaded by calling #clear_changesets
  # before fetching changesets (eg. for offline resync)
  def fetch_changesets
    self.scm_metadata ||= {}
    revisions = []
    branches.each do |branch|
      last_checked_revision = scm_metadata[branch]
      branch_revisions = scm.revisions('', last_checked_revision, branch)

      revisions += branch_revisions
      scm_metadata[branch] = branch_revisions.first.scmid if branch_revisions && branch_revisions.first
    end

    return if revisions.nil? || revisions.empty?

    # Save scm metadata
    save

    # Save the remaining ones to the database
    revisions.each{|r| r.save(self)} unless revisions.nil?
  end

  def latest_changesets(path,rev,limit=10)
    revisions = scm.revisions(path, nil, rev, :limit => limit, :all => false)
    return [] if revisions.nil? || revisions.empty?

    changesets.find(
      :all, 
      :conditions => [
        "scmid IN (?)", 
        revisions.map!{|c| c.scmid}
      ],
      :order => 'committed_on DESC'
    )
  end
end
