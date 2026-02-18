class Medication < ApplicationRecord
  belongs_to :pet
  has_many :health_records

  validates :medication_name, presence: true
  validates :dose, presence: true
  validates :start_date, presence: true

  scope :active, -> { where('end_date IS NULL OR end_date >= ?', Date.today) }
  scope :inactive, -> { where('end_date < ?', Date.today) }

  def active?
    end_date.nil? || end_date >= Date.today
  end
end
