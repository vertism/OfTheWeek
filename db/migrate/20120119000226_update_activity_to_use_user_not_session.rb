class UpdateActivityToUseUserNotSession < ActiveRecord::Migration
  def up
    remove_column :activities, :session
    add_column :activities, :user, :string
  end

  def down
  end
end
