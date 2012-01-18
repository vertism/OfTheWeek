class AddPhotoSizes < ActiveRecord::Migration
  def up
    add_column :photos, :url_original, :string
    add_column :photos, :url_thumbnail, :string
    rename_column :photos, :url, :url_square
  end

  def down
    remove_column :photos, :url_original
    remove_column :photos, :url_thumbnail
    rename_column :photos, :url_square, :url
  end
end
