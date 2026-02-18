class MedicationDosage < ApplicationRecord
  belongs_to :medication
  
  validates :dose, presence: true, numericality: { greater_than: 0 }
  validates :recorded_on, presence: true
  
  scope :ordered, -> { order(recorded_on: :asc) }
end
