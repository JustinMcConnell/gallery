class AddSizeAndAccessedToImage < ActiveRecord::Migration
  def change
    add_column :images, :size, :integer
    add_column :images, :times_accessed, :integer
  end
end
