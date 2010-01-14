class AddEnteredByToJournals < ActiveRecord::Migration
  def self.up
    add_column :journals, :entered_by_id, :integer
    add_index :journals, :entered_by_id
  end

  def self.down
    remove_index :journals, :entered_by_id
    remove_column :journals, :entered_by_id
  end
end
