class DismissedAlert < ApplicationRecord
  belongs_to :pet

  validates :alert_type, presence: true
  validates :alert_condition, presence: true
  validates :dismissed_at, presence: true

  # Check if a specific alert condition has been dismissed for a pet
  def self.dismissed?(pet, alert_type, alert_condition)
    exists?(pet: pet, alert_type: alert_type, alert_condition: alert_condition)
  end

  # Dismiss an alert for a pet
  def self.dismiss(pet, alert_type, alert_condition)
    find_or_create_by(pet: pet, alert_type: alert_type, alert_condition: alert_condition) do |alert|
      alert.dismissed_at = Time.current
    end
  end
end
