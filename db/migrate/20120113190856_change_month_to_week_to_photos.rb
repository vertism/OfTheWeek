class ChangeMonthToWeekToPhotos < ActiveRecord::Migration
  def up
    remove_column :photos, :month
    remove_column :photos, :tags
    add_column :photos, :week, :integer
    add_column :photos, :tag, :string
  end

  def down
    remove_column :photos, :week
    remove_column :photos, :tag
    add_column :photos, :month, :integer
    add_column :photos, :tags, :string
  end
end
