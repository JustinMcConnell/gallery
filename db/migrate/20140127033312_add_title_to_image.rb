class AddTitleToImage < ActiveRecord::Migration
  def change
    add_column :images, :title, :text
  end
end
