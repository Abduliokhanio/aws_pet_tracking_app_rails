require "test_helper"

class DataIntegrityTest < ActiveSupport::TestCase
  # Property 48: Pet deletion cascade
  # Validates: Requirements 11.1
  # For any pet with associated health records, medications, and reminders,
  # deleting the pet should also delete all associated records.
  test "property: pet deletion cascade" do
    Rantly(20) do
      # Create a user and pet
      user = User.create!(
        name: "Test User #{rand(10000)}",
        gender: choose("male", "female"),
        ssn: sprintf("%09d", range(100000000, 999999999))
      )
      pet = Pet.create!(
        user: user,
        name: "Pet #{rand(10000)}",
        species: choose("dog", "cat", "bird", "rabbit")
      )
      
      # Generate random number of associated records
      num_health_records = range(1, 5)
      num_medications = range(1, 5)
      num_reminders = range(1, 5)
      
      # Create health records
      health_record_ids = Array.new(num_health_records) do
        HealthRecord.create!(
          pet: pet,
          recorded_on: Date.today - range(0, 365).days,
          weight: range(1, 5000) / 100.0
        ).id
      end
      
      # Create medications
      medication_ids = Array.new(num_medications) do
        Medication.create!(
          pet: pet,
          medication_name: "Medication #{rand(10000)}",
          dose: "#{range(1, 100)}mg",
          start_date: Date.today - range(0, 365).days
        ).id
      end
      
      # Create reminders
      reminder_ids = Array.new(num_reminders) do
        Reminder.create!(
          pet: pet,
          reminder_type: choose("vet_appointment", "medication", "grooming", "custom"),
          scheduled_date: Date.today + range(1, 365).days,
          title: "Reminder #{rand(10000)}"
        ).id
      end
      
      # Verify all records exist before deletion
      guard HealthRecord.where(id: health_record_ids).count == num_health_records
      guard Medication.where(id: medication_ids).count == num_medications
      guard Reminder.where(id: reminder_ids).count == num_reminders
      
      # Delete the pet
      pet.destroy!
      
      # Verify all associated records are deleted (cascade)
      guard HealthRecord.where(id: health_record_ids).count == 0
      guard Medication.where(id: medication_ids).count == 0
      guard Reminder.where(id: reminder_ids).count == 0
      
      # Verify the pet itself is deleted
      guard Pet.where(id: pet.id).count == 0
      
      # Clean up user
      user.destroy
    end
  end

  # Property 49: User deletion cascade
  # Validates: Requirements 11.2
  # For any user with associated pets, deleting the user should also delete
  # all pets and their associated health data.
  test "property: user deletion cascade" do
    Rantly(20) do
      # Create a user
      user = User.create!(
        name: "Test User #{rand(10000)}",
        gender: choose("male", "female"),
        ssn: sprintf("%09d", range(100000000, 999999999))
      )
      
      # Generate random number of pets
      num_pets = range(1, 3)
      
      pet_ids = []
      all_health_record_ids = []
      all_medication_ids = []
      all_reminder_ids = []
      
      # Create pets with associated data
      num_pets.times do
        pet = Pet.create!(
          user: user,
          name: "Pet #{rand(10000)}",
          species: choose("dog", "cat", "bird", "rabbit")
        )
        pet_ids << pet.id
        
        # Create health records for this pet
        num_health_records = range(1, 3)
        num_health_records.times do
          hr = HealthRecord.create!(
            pet: pet,
            recorded_on: Date.today - range(0, 365).days,
            weight: range(1, 5000) / 100.0
          )
          all_health_record_ids << hr.id
        end
        
        # Create medications for this pet
        num_medications = range(1, 3)
        num_medications.times do
          med = Medication.create!(
            pet: pet,
            medication_name: "Medication #{rand(10000)}",
            dose: "#{range(1, 100)}mg",
            start_date: Date.today - range(0, 365).days
          )
          all_medication_ids << med.id
        end
        
        # Create reminders for this pet
        num_reminders = range(1, 3)
        num_reminders.times do
          rem = Reminder.create!(
            pet: pet,
            reminder_type: choose("vet_appointment", "medication", "grooming", "custom"),
            scheduled_date: Date.today + range(1, 365).days,
            title: "Reminder #{rand(10000)}"
          )
          all_reminder_ids << rem.id
        end
      end
      
      # Verify all records exist before deletion
      guard Pet.where(id: pet_ids).count == num_pets
      guard HealthRecord.where(id: all_health_record_ids).count == all_health_record_ids.size
      guard Medication.where(id: all_medication_ids).count == all_medication_ids.size
      guard Reminder.where(id: all_reminder_ids).count == all_reminder_ids.size
      
      # Delete the user
      user.destroy!
      
      # Verify all pets are deleted (cascade)
      guard Pet.where(id: pet_ids).count == 0
      
      # Verify all health data is deleted (cascade through pets)
      guard HealthRecord.where(id: all_health_record_ids).count == 0
      guard Medication.where(id: all_medication_ids).count == 0
      guard Reminder.where(id: all_reminder_ids).count == 0
      
      # Verify the user itself is deleted
      guard User.where(id: user.id).count == 0
    end
  end

  # Property 50: Vet office deletion cascade
  # Validates: Requirements 11.3
  # For any vet office with an associated address and contacts, deleting the
  # office should also delete the address and contacts.
  test "property: vet office deletion cascade" do
    Rantly(20) do
      # Create a vet office
      vet_office = VetOffice.create!(name: "Vet Office #{rand(10000)}")
      
      # Create an address for the vet office
      address = Address.create!(
        vet_office: vet_office,
        city: "City #{rand(1000)}",
        state: choose("CA", "NY", "TX", "FL", "WA"),
        zipcode: sprintf("%05d", range(10000, 99999)),
        country: "US"
      )
      address_id = address.id
      
      # Generate random number of contacts
      num_contacts = range(1, 5)
      
      contact_ids = Array.new(num_contacts) do
        contact_type = choose("phone", "email")
        contact_value = if contact_type == "phone"
          sprintf("%010d", range(1000000000, 9999999999))
        else
          "contact#{rand(10000)}@example.com"
        end
        
        Contact.create!(
          vet_office: vet_office,
          contact_type: contact_type,
          contact_value: contact_value,
          is_primary: false
        ).id
      end
      
      # Verify all records exist before deletion
      guard Address.where(id: address_id).count == 1
      guard Contact.where(id: contact_ids).count == num_contacts
      
      # Delete the vet office
      vet_office.destroy!
      
      # Verify the address is deleted (cascade)
      guard Address.where(id: address_id).count == 0
      
      # Verify all contacts are deleted (cascade)
      guard Contact.where(id: contact_ids).count == 0
      
      # Verify the vet office itself is deleted
      guard VetOffice.where(id: vet_office.id).count == 0
    end
  end

  # Property 51: Veterinarian deletion restriction
  # Validates: Requirements 11.4
  # For any veterinarian with associated ratings, attempting to delete the
  # veterinarian should fail with an error.
  test "property: veterinarian deletion restriction" do
    Rantly(20) do
      # Create a vet office
      vet_office = VetOffice.create!(name: "Vet Office #{rand(10000)}")
      
      # Create an address for the vet office (required)
      Address.create!(
        vet_office: vet_office,
        city: "City #{rand(1000)}",
        state: choose("CA", "NY", "TX", "FL", "WA"),
        zipcode: sprintf("%05d", range(10000, 99999)),
        country: "US"
      )
      
      # Create a veterinarian
      veterinarian = Veterinarian.create!(
        vet_office: vet_office,
        name: "Dr. #{rand(10000)}",
        years_of_experience: range(1, 40)
      )
      
      # Create users for ratings
      num_ratings = range(1, 5)
      user_ids = []
      rating_ids = []
      
      num_ratings.times do
        user = User.create!(
          name: "User #{rand(10000)}",
          gender: choose("male", "female"),
          ssn: sprintf("%09d", range(100000000, 999999999))
        )
        user_ids << user.id
        
        rating = Rating.create!(
          veterinarian: veterinarian,
          user: user,
          rating_value: range(1, 5),
          review_text: choose(nil, "Great vet!", "Very professional", "Excellent care")
        )
        rating_ids << rating.id
      end
      
      # Verify ratings exist
      guard Rating.where(id: rating_ids).count == num_ratings
      
      # Attempt to delete the veterinarian should fail
      deletion_failed = false
      error_raised = false
      
      begin
        veterinarian.destroy!
      rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::RecordNotDestroyed => e
        deletion_failed = true
        error_raised = true
      end
      
      # Verify deletion failed
      guard deletion_failed
      guard error_raised
      
      # Verify the veterinarian still exists
      guard Veterinarian.exists?(veterinarian.id)
      
      # Verify all ratings still exist
      guard Rating.where(id: rating_ids).count == num_ratings
      
      # Clean up: delete ratings first, then veterinarian, then users
      Rating.where(id: rating_ids).destroy_all
      veterinarian.destroy
      User.where(id: user_ids).destroy_all
      vet_office.destroy
    end
  end
end
