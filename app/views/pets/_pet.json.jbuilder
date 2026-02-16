json.extract! pet, :id, :name, :gender, :species, :user_id, :created_at, :updated_at
json.url pet_url(pet, format: :json)
