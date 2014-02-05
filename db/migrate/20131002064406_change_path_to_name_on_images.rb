class ChangePathToNameOnImages < ActiveRecord::Migration
  def change
    change_table :images do |table|
      table.rename :path, :name
    end
  end
end
