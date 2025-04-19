class AuditLog < ApplicationRecord
  belongs_to :booking
  
  enum action: { created: 0, cancelled: 1 }
  
  validates :action, :details, presence: true
end