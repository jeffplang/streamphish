class CreateVenues < ActiveRecord::Migration
  def change
    create_table :venues do |t|
      t.string      :name
      t.string      :past_names
      t.string      :city
      t.string      :state
      t.string      :country
      t.timestamps
    end
    
    add_index :songs, :venue_id
    add_index :venues, :name
  end
end
