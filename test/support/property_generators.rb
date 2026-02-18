# Property-based test generators for common data types
module PropertyGenerators
  # Generate random dates within a reasonable range
  def self.random_date(start_date: 2.years.ago.to_date, end_date: Date.today)
    days_between = (end_date - start_date).to_i
    start_date + rand(0..days_between).days
  end

  # Generate random future dates
  def self.random_future_date(from: Date.today, max_days: 365)
    from + rand(1..max_days).days
  end

  # Generate random past dates
  def self.random_past_date(from: Date.today, max_days: 365)
    from - rand(1..max_days).days
  end

  # Generate random weights with proper precision (5,2)
  def self.random_weight(min: 0.1, max: 200.0)
    weight = rand(min..max)
    weight.round(2)
  end

  # Generate random pet names
  def self.random_pet_name
    names = [
      "Buddy", "Max", "Charlie", "Luna", "Bella", "Cooper", "Daisy",
      "Rocky", "Molly", "Tucker", "Sadie", "Bear", "Maggie", "Duke",
      "Lucy", "Jack", "Bailey", "Sophie", "Zeus", "Chloe"
    ]
    names.sample
  end

  # Generate random user names
  def self.random_user_name
    first_names = ["John", "Jane", "Mike", "Sarah", "David", "Emily", "Chris", "Lisa"]
    last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller"]
    "#{first_names.sample} #{last_names.sample}"
  end

  # Generate random email addresses
  def self.random_email
    "user#{rand(1000..9999)}@example.com"
  end

  # Generate random phone numbers
  def self.random_phone
    "#{rand(200..999)}#{rand(200..999)}#{rand(1000..9999)}"
  end

  # Generate random medication names
  def self.random_medication_name
    medications = [
      "Amoxicillin", "Prednisone", "Carprofen", "Gabapentin", "Tramadol",
      "Metronidazole", "Cephalexin", "Doxycycline", "Meloxicam", "Apoquel"
    ]
    medications.sample
  end

  # Generate random medication doses
  def self.random_medication_dose
    doses = ["5mg", "10mg", "25mg", "50mg", "100mg", "1ml", "2ml", "5ml"]
    doses.sample
  end

  # Generate random species
  def self.random_species
    ["dog", "cat", "bird", "rabbit", "hamster"].sample
  end

  # Generate random mood values
  def self.random_mood
    ["happy", "calm", "anxious", "playful", "lethargic", "aggressive"].sample
  end

  # Generate random activity levels
  def self.random_activity_level
    ["very_high", "high", "normal", "low", "very_low"].sample
  end

  # Generate random food intake values
  def self.random_food_intake
    ["excellent", "good", "fair", "poor", "none"].sample
  end

  # Generate random status values
  def self.random_status
    ["excellent", "good", "fair", "poor", "critical"].sample
  end

  # Generate random reminder types
  def self.random_reminder_type
    ["vet_appointment", "medication", "grooming", "custom"].sample
  end

  # Generate random contact types
  def self.random_contact_type
    ["phone", "email"].sample
  end

  # Generate random US zipcode
  def self.random_zipcode
    format("%05d", rand(10000..99999))
  end

  # Generate random city name
  def self.random_city
    cities = ["New York", "Los Angeles", "Chicago", "Houston", "Phoenix", "Philadelphia"]
    cities.sample
  end

  # Generate random US state
  def self.random_state
    states = ["NY", "CA", "TX", "FL", "IL", "PA", "OH", "GA", "NC", "MI"]
    states.sample
  end

  # Generate random rating value (1-5)
  def self.random_rating
    rand(1..5)
  end

  # Generate random years of experience
  def self.random_years_experience
    rand(0..40)
  end
end
