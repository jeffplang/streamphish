class AddSpecialTagToShow < ActiveRecord::Migration
  def change
    add_column :shows, :special_tag, :string
  end
end
