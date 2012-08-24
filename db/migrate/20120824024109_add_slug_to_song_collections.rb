class AddSlugToSongCollections < ActiveRecord::Migration
  def change
    add_column :song_collections, :slug, :string
  end
end
