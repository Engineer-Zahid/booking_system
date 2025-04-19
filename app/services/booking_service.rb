# app/services/booking_service.rb
class BookingService
  def self.create_booking(user, room_ids, start_time, end_time)
    ActiveRecord::Base.transaction do
      bookings = []
      
      Room.where(id: room_ids).active.each do |room|
        booking = user.bookings.new(
          room: room,
          start_time: start_time,
          end_time: end_time,
          status: :confirmed
        )
        
        if booking.save
          AuditLog.create!(
            booking: booking,
            action: :created,
            details: "Booking created for room #{room.name} from #{start_time} to #{end_time}"
          )
          
          bookings << booking
        else
          raise ActiveRecord::Rollback, "Booking failed: #{booking.errors.full_messages.join(', ')}"
        end
      end
      
      bookings
    end
  rescue ActiveRecord::Rollback => e
    { error: e.message }
  end
  
  def self.cancel_booking(booking)
    ActiveRecord::Base.transaction do
      booking.update!(status: :cancelled)
      booking.apply_cancellation_fee
      booking.save!
      
      AuditLog.create!(
        booking: booking,
        action: :cancelled,
        details: "Booking cancelled. Refund amount: #{booking.total_price}"
      )
      
      booking
    end
  rescue => e
    { error: e.message }
  end
end