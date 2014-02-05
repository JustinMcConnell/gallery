class RenameTimesAccessedToViewsInImages < ActiveRecord::Migration
  def change
    change_table :images do |table|
      table.rename :times_accessed, :views
    end
  end
end
