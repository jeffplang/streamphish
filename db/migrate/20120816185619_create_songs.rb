class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.references :show
      t.string :title
      t.integer :position
      t.timestamps
    end
  end
end
