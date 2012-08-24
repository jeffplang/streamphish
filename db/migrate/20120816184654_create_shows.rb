class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.date 'show_date'
      t.timestamps
    end
  end
end
