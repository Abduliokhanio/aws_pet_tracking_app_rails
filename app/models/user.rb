class User < ApplicationRecord
  has_many :pets, dependent: :destroy
  has_many :ratings, dependent: :destroy
end
