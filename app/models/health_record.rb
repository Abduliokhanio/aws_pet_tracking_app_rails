class HealthRecord < ApplicationRecord
  belongs_to :pet
  belongs_to :medication, optional: true
  
  validates :recorded_on, presence: true
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :status, inclusion: { in: %w[excellent good fair poor critical] }, allow_nil: true
  
  scope :chronological, -> { order(recorded_on: :desc) }
  scope :recent, -> { where('recorded_on >= ?', 30.days.ago) }
  scope :with_weight, -> { where.not(weight: nil) }
  
  after_create :check_health_thresholds
  
  private
  
  def check_health_thresholds
    HealthAlertService.new(self).check_and_alert
  end
end
