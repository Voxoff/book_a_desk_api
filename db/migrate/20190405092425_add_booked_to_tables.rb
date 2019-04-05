class AddBookedToTables < ActiveRecord::Migration[5.2]
  def change
    add_column :tables, :booked, :boolean
  end
end
