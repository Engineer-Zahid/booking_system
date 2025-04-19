class Room < ApplicationRecord
  has_many :bookings, dependent: :destroy
  
  validates :name, presence: true, uniqueness: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_per_hour, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  scope :active, -> { where(active: true) }
  scope :available_between, ->(start_time, end_time) {
  left_joins(:bookings).where(
    "(bookings.id IS NULL) OR " \
    "(bookings.status IN (?) AND NOT (? <= bookings.end_time AND ? >= bookings.start_time))",
    [Booking.statuses[:cancelled]],
    start_time,
    end_time
  ).distinct
}

end