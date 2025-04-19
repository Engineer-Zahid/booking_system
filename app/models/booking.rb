class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :room
  has_many :audit_logs
  enum status: { pending: 0, confirmed: 1, cancelled: 2 }
  
  validates :start_time, :end_time, :status, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_bookings
  validate :active_room
  validate :max_three_rooms_per_transaction, on: :create
  
  before_save :calculate_total_price
  
  def duration_in_hours
    (end_time - start_time) / 3600.0
  end
  
  def apply_cancellation_fee
    if cancelled? && (Time.now - created_at) <= 24.hours
      self.total_price *= 0.95
    end
  end
  
  private
  
  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
  
  def no_overlapping_bookings
    return if room.blank? || start_time.blank? || end_time.blank?
    
    overlapping = room.bookings.where.not(id: id)
                     .where.not(status: 'cancelled')
                     .where("(? <= end_time) AND (? >= start_time)", start_time, end_time)
    
    if overlapping.exists?
      errors.add(:base, "The room is already booked for the selected time slot")
    end
  end
  
  def active_room
    return if room.blank?
    
    unless room.active?
      errors.add(:room, "is not available for booking")
    end
  end
  
  def max_three_rooms_per_transaction
    return unless user.present? && new_record?
    
    transaction_bookings = user.bookings.where(created_at: Time.now - 5.minutes..Time.now)
    if transaction_bookings.count >= 3
      errors.add(:base, "Cannot book more than 3 rooms in a single transaction")
    end
  end
  
  def calculate_total_price
    return unless room.present? && start_time.present? && end_time.present?
    
    hours = duration_in_hours
    self.total_price = room.price_per_hour * hours
    
    if hours > 4
      self.total_price *= 0.9
    end
  end
end