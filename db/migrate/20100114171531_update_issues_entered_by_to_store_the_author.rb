class UpdateIssuesEnteredByToStoreTheAuthor < ActiveRecord::Migration
  def self.up
    Issue.all(:conditions => {:entered_by_id => nil}).each do |issue|
      issue.update_attribute(:entered_by_id, issue.author_id)
    end
  end

  def self.down
    # No-op
  end
end
