class AddSlugToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :slug, :string
    add_index :tracks, :slug
  end
end
