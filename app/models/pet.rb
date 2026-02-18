class Pet < ApplicationRecord
  belongs_to :user
  has_many :health_records, dependent: :destroy
  has_many :medications, dependent: :destroy
  has_many :reminders, dependent: :destroy
end
