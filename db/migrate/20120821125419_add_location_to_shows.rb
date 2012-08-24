class AddLocationToShows < ActiveRecord::Migration
  def change
    add_column :shows, :location, :string
  end
end
