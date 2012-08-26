class CreateSectionMarkers < ActiveRecord::Migration
  def change
    create_table :section_markers do |t|
      t.string :title
      t.integer :position
      t.references :song
      t.timestamps
    end
  end
end
