class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.string :tags
      t.integer :year
      t.integer :month
      t.string :url

      t.timestamps
    end
  end
end
