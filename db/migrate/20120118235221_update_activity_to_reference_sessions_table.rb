class UpdateActivityToReferenceSessionsTable < ActiveRecord::Migration
  def up
    remove_column :activities, :user
    add_column :activities, :session, :integer
  end

  def down
  end
end
