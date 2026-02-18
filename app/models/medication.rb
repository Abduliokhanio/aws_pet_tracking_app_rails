class Medication < ApplicationRecord
  belongs_to :pet
  has_many :health_records
  has_many :medication_dosages, dependent: :destroy

  validates :medication_name, presence: true
  validates :dose, presence: true
  validates :start_date, presence: true

  scope :active, -> { where('end_date IS NULL OR end_date >= ?', Date.today) }
  scope :inactive, -> { where('end_date < ?', Date.today) }

  def active?
    end_date.nil? || end_date >= Date.today
  end
  
  # Get dosage history for graphing
  def dosage_history
    medication_dosages.ordered
  end
end
