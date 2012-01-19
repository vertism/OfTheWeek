class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :user
      t.references :photo

      t.timestamps
    end
    
    add_index :activities, :user
  end
end
