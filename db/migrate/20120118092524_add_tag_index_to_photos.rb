class AddTagIndexToPhotos < ActiveRecord::Migration
  def change
    add_index :photos, :tag
    add_index :photos, :year
    add_index :photos, :week
    add_column :photos, :views, :integer
  end
end
