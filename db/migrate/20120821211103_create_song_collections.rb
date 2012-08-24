class CreateSongCollections < ActiveRecord::Migration
  def change
    create_table :song_collections do |t|
      t.string :title
      t.timestamps
    end
  end
end
