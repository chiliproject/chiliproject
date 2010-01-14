class UpdateJournalsEnteredByToStoreTheAuthor < ActiveRecord::Migration
  def self.up
    Journal.all(:conditions => {:entered_by_id => nil}).each do |journal|
      journal.update_attribute(:entered_by_id, journal.user_id)
    end
  end

  def self.down
    # No-op
  end
end
