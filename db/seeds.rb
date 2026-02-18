# Clear existing data in correct order (respecting foreign keys)
puts "Clearing existing data..."
Rating.destroy_all
DismissedAlert.destroy_all
PetHealthThreshold.destroy_all
Reminder.destroy_all
Medication.destroy_all
HealthRecord.destroy_all
Veterinarian.destroy_all
Contact.destroy_all
Address.destroy_all
VetOffice.destroy_all
Pet.destroy_all
User.destroy_all

puts "Creating users..."
users = []
5.times do |i|
  users << User.create!(
    name: ["John Doe", "Jane Smith", "Bob Johnson", "Alice Williams", "Charlie Brown"][i],
    gender: ["m", "f", "m", "f", "m"][i],
    ssn: "#{rand(100..999)}-#{rand(10..99)}-#{rand(1000..9999)}"
  )
end

puts "Creating pets..."
pet_names = ["Max", "Bella", "Charlie", "Luna", "Cooper", "Daisy", "Rocky", "Lucy", "Buddy", "Molly", "Duke", "Sadie", "Bear", "Maggie", "Zeus"]
species_list = ["dog", "cat", "dog", "cat", "dog", "cat", "dog", "cat", "dog", "cat", "dog", "cat", "dog", "cat", "dog"]
genders = ["m", "f", "m", "f", "m", "f", "m", "f", "m", "f", "m", "f", "m", "f", "m"]

pets = []
15.times do |i|
  pets << Pet.create!(
    name: pet_names[i],
    species: species_list[i],
    gender: genders[i],
    user: users[i % 5]
  )
end

puts "Creating health records..."
pets.each do |pet|
  # Create 5-10 health records per pet
  rand(5..10).times do
    days_ago = rand(1..60)
    HealthRecord.create!(
      pet: pet,
      recorded_on: days_ago.days.ago.to_date,
      weight: rand(5.0..50.0).round(2),
      mood: ["happy", "calm", "anxious", "playful", "tired"].sample,
      activity_level: ["low", "moderate", "high", "very_high"].sample,
      food_intake: ["poor", "normal", "good", "excellent"].sample,
      status: ["excellent", "good", "fair", "poor"].sample,
      notes: "Regular checkup - all vitals normal"
    )
  end
end

puts "Creating medications..."
medication_names = ["Amoxicillin", "Carprofen", "Fipronil", "Ivermectin", "Cetirizine", "Prednisone", "Metronidazole"]
medications = []
pets.each do |pet|
  # Create 1-3 medications per pet
  rand(1..3).times do
    days_ago = rand(1..30)
    start_date = days_ago.days.ago.to_date
    initial_dose = rand(5.0..500.0).round(2)
    
    medication = Medication.create!(
      pet: pet,
      medication_name: medication_names.sample,
      dose: initial_dose, # Current/latest dosage
      start_date: start_date,
      end_date: [nil, (start_date + rand(7..30).days)].sample,
      notes: "Prescribed by veterinarian - #{['once daily', 'twice daily', 'three times daily', 'weekly'].sample}"
    )
    medications << medication
  end
end

puts "Creating medication dosage history..."
medications.each do |medication|
  # Create initial dosage record
  MedicationDosage.create!(
    medication: medication,
    dose: medication.dose,
    recorded_on: medication.start_date,
    notes: "Initial dosage"
  )
  
  # Randomly create 1-3 dosage changes for some medications
  if rand < 0.5 # 50% chance of having dosage changes
    changes = rand(1..3)
    changes.times do |i|
      days_after_start = rand(3..20)
      change_date = medication.start_date + days_after_start.days
      
      # Only create if within medication period
      if medication.end_date.nil? || change_date <= medication.end_date
        new_dose = (medication.dose * rand(0.5..1.5)).round(2)
        MedicationDosage.create!(
          medication: medication,
          dose: new_dose,
          recorded_on: change_date,
          notes: ["Dosage adjusted", "Increased dosage", "Decreased dosage", "Dosage modified per vet"].sample
        )
        # Update medication's current dose to the latest
        medication.update(dose: new_dose)
      end
    end
  end
end

puts "Creating reminders..."
reminder_types = ["vet_appointment", "medication", "grooming", "custom"]
pets.each do |pet|
  # Create 2-5 reminders per pet
  rand(2..5).times do
    scheduled_date = rand(-5..30).days.from_now.to_date
    completed = scheduled_date < Date.today ? [true, false].sample : false
    
    Reminder.create!(
      pet: pet,
      reminder_type: reminder_types.sample,
      scheduled_date: scheduled_date,
      title: ["Annual Checkup", "Vaccination Due", "Medication Refill", "Grooming Appointment", "Dental Cleaning"].sample,
      description: "Don't forget this important appointment!",
      completed_at: completed ? scheduled_date : nil,
      status: completed ? "completed" : (scheduled_date <= Date.today ? "due" : "pending")
    )
  end
end

puts "Creating vet offices..."
vet_offices = []
3.times do |i|
  office = VetOffice.create!(
    name: ["Paws & Claws Veterinary Clinic", "Happy Tails Animal Hospital", "Pet Care Center"][i]
  )
  
  Address.create!(
    vet_office: office,
    city: ["San Francisco", "Los Angeles", "Seattle"][i],
    state: ["CA", "CA", "WA"][i],
    zipcode: ["94102", "90001", "98101"][i],
    country: "USA"
  )
  
  Contact.create!(
    vet_office: office,
    contact_type: "phone",
    contact_value: "#{rand(1000000000..9999999999)}",
    is_primary: true
  )
  
  Contact.create!(
    vet_office: office,
    contact_type: "email",
    contact_value: "info@#{office.name.downcase.gsub(/[^a-z]/, '')}.com",
    is_primary: false
  )
  
  vet_offices << office
end

puts "Creating veterinarians..."
vet_names = ["Dr. Sarah Johnson", "Dr. Michael Chen", "Dr. Emily Rodriguez", "Dr. David Kim", "Dr. Lisa Martinez"]
vet_offices.each do |office|
  rand(1..2).times do
    vet = Veterinarian.create!(
      vet_office: office,
      name: vet_names.sample,
      work_history: "Specialized in small animal care with #{rand(5..20)} years of experience",
      years_of_experience: rand(5..20)
    )
    
    # Create some ratings
    users.sample(rand(1..3)).each do |user|
      Rating.create!(
        veterinarian: vet,
        user: user,
        rating_value: rand(3..5),
        review_text: ["Excellent care!", "Very knowledgeable and caring", "Great with my pet", "Highly recommend"].sample
      )
    end
  end
end

puts "Creating custom health thresholds..."
threshold_types = ["min_weight", "max_weight", "min_activity", "alert_sensitivity"]
pets.sample(5).each do |pet|
  PetHealthThreshold.create!(
    pet: pet,
    threshold_type: threshold_types.sample,
    threshold_value: rand(5..15)
  )
end

puts "\n✅ Seed data created successfully!"
puts "📊 Summary:"
puts "  - #{User.count} users"
puts "  - #{Pet.count} pets"
puts "  - #{HealthRecord.count} health records"
puts "  - #{Medication.count} medications"
puts "  - #{MedicationDosage.count} medication dosage records"
puts "  - #{Reminder.count} reminders"
puts "  - #{VetOffice.count} vet offices"
puts "  - #{Veterinarian.count} veterinarians"
puts "  - #{Rating.count} ratings"
