class AddConcertSets < ActiveRecord::Migration
  def up
    create_table :concert_sets do |t|
      t.references :show
      t.string :title
      t.timestamps
    end
    add_column :tracks, :concert_set_id, :integer
  end

  def down
    drop_table :concert_sets if table_exists?(:concert_sets)
    remove_column :tracks, :concert_set_id if column_exists?(:tracks, :concert_set_id)
  end
end
