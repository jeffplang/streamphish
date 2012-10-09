class AddSbdFieldToShows < ActiveRecord::Migration
  def change
    add_column :shows, :sbd, :boolean, :default => false
  end
end
