class Address < ApplicationRecord
  belongs_to :vet_office
  
  validates :city, :state, :zipcode, :country, presence: true
  validates :zipcode, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be valid US format" }, 
                      if: -> { country == 'US' }
  
  def formatted
    "#{city}, #{state} #{zipcode}, #{country}"
  end
end
