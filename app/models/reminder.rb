class Reminder < ApplicationRecord
  belongs_to :pet
  
  validates :reminder_type, inclusion: { in: %w[vet_appointment medication grooming custom] }
  validates :scheduled_date, presence: true
  validates :title, presence: true
  
  scope :upcoming, -> { where('scheduled_date > ? AND completed_at IS NULL', Date.today) }
  scope :due, -> { where('scheduled_date <= ? AND completed_at IS NULL', Date.today) }
  scope :completed, -> { where.not(completed_at: nil) }
  
  def due?
    scheduled_date <= Date.today && completed_at.nil?
  end
  
  def complete!
    update(completed_at: Time.current)
  end
end
