class Rating < ApplicationRecord
  belongs_to :veterinarian
  belongs_to :user
  
  validates :rating_value, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :veterinarian_id, message: "can only rate once per veterinarian" }
  
  after_save :update_veterinarian_cache
  after_destroy :update_veterinarian_cache
  
  private
  
  def update_veterinarian_cache
    veterinarian.touch # Triggers cache invalidation
  end
end
