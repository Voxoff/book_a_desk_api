class Booking < ApplicationRecord
  belongs_to :table
  belongs_to :user
end
