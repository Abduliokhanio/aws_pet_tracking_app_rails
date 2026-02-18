class PetHealthThreshold < ApplicationRecord
  belongs_to :pet

  validates :threshold_type, presence: true, inclusion: { in: %w[min_weight max_weight min_activity alert_sensitivity] }
  validates :threshold_value, presence: true, numericality: { greater_than: 0 }
  validates :threshold_type, uniqueness: { scope: :pet_id }
end
