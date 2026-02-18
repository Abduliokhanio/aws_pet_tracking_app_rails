class Veterinarian < ApplicationRecord
  belongs_to :vet_office
  has_many :ratings, dependent: :restrict_with_error
  
  validates :name, presence: true
  validates :years_of_experience, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  
  def average_rating
    ratings.average(:rating_value).to_f.round(2)
  end
  
  def total_ratings
    ratings.count
  end
end
