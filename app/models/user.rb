class User < ApplicationRecord
  enum role: { customer: 0, admin: 1 }
  
  has_many :bookings, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  def total_spent
    bookings.where(status: :confirmed).sum(:total_price)
  end
end
