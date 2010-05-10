class CreateTestDummies < ActiveRecord::Migration
  def self.up
    create_table :test_dummies do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :test_dummies
  end
end
