class VetOffice < ApplicationRecord
  has_one :address, dependent: :destroy
  has_many :contacts, dependent: :destroy
  # has_many :veterinarians, dependent: :nullify  # TODO: Uncomment when Veterinarian model is created (task 7.1)
  
  validates :name, presence: true
  
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :contacts, allow_destroy: true
  
  def primary_phone
    contacts.find_by(contact_type: 'phone', is_primary: true)
  end
  
  def primary_email
    contacts.find_by(contact_type: 'email', is_primary: true)
  end
end
