class CreateBookings < ActiveRecord::Migration[5.2]
  def change
    create_table :bookings do |t|
      t.references :table, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :date
      t.boolean :morning

      t.timestamps
    end
  end
end
