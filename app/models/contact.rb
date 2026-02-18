class Contact < ApplicationRecord
  belongs_to :vet_office
  
  validates :contact_type, inclusion: { in: %w[phone email] }
  validates :contact_value, presence: true
  validates :contact_value, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { contact_type == 'email' }
  validates :contact_value, format: { with: /\A\d{10,15}\z/ }, if: -> { contact_type == 'phone' }
  
  before_save :ensure_single_primary_per_type
  
  private
  
  def ensure_single_primary_per_type
    if is_primary? && is_primary_changed?
      Contact.where(vet_office: vet_office, contact_type: contact_type, is_primary: true)
             .where.not(id: id)
             .update_all(is_primary: false)
    end
  end
end
