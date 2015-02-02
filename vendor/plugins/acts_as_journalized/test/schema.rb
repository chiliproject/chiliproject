#-- encoding: UTF-8

class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :test_users, :force => true do |t|
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end

CreateSchema.suppress_messages do
  CreateSchema.migrate(:up)
end

class TestUser < ActiveRecord::Base
  acts_as_journalized

  def name
    [first_name, last_name].compact.join(' ')
  end

  def name=(names)
    self[:first_name], self[:last_name] = names.split(' ', 2)
  end
end
