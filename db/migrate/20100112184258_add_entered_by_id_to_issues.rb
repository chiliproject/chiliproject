class AddEnteredByIdToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :entered_by_id, :integer

    add_index :issues, :entered_by_id
  end

  def self.down
    remove_index :issues, :entered_by_id
    remove_column :issues, :entered_by_id
  end
end
