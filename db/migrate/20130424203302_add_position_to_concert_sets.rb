class AddPositionToConcertSets < ActiveRecord::Migration
  def change
    add_column :concert_sets, :position, :integer
  end
end
