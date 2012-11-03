class CreateSectionMarkers < ActiveRecord::Migration
  def change
    create_table :section_markers do |t|
      t.references    :track
      t.string        :title
      t.integer       :position
      t.timestamps
    end
    
    add_index :section_markers, :track_id
  end
end
