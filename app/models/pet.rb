class Pet < ApplicationRecord
  belongs_to :user
  has_many :health_records, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :reminders, dependent: :destroy
  has_many :pet_health_thresholds, dependent: :destroy
  has_many :dismissed_alerts, dependent: :destroy
end
