require "test_helper"

class MedicationTest < ActiveSupport::TestCase
  # Property 12: Medication required fields
  # Validates: Requirements 3.1
  # For any medication creation attempt, the medication should be rejected if
  # medication_name, dose, or start_date is missing, and accepted when all are present.
  test "property: medication required fields" do
    pet = pets(:one)
    
    Rantly(100) do
      # Generate random optional attributes
      end_date = choose(nil, Date.today + range(1, 365).days)
      notes = choose(nil, "Test notes", "Important medication", "As prescribed")
      
      # Generate valid values for required fields
      medication_name = choose("Aspirin", "Antibiotics", "Insulin", "Prednisone", "Gabapentin")
      dose = choose("5mg", "10mg", "20mg", "1ml", "2ml", "50mg twice daily")
      start_date = Date.today - range(0, 365).days
      
      # Test 1: Medication WITHOUT medication_name should be rejected
      med_without_name = Medication.new(
        pet: pet,
        dose: dose,
        start_date: start_date,
        end_date: end_date,
        notes: notes
      )
      guard !med_without_name.valid?
      guard med_without_name.errors[:medication_name].present?
      
      # Test 2: Medication WITHOUT dose should be rejected
      med_without_dose = Medication.new(
        pet: pet,
        medication_name: medication_name,
        start_date: start_date,
        end_date: end_date,
        notes: notes
      )
      guard !med_without_dose.valid?
      guard med_without_dose.errors[:dose].present?
      
      # Test 3: Medication WITHOUT start_date should be rejected
      med_without_start = Medication.new(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        end_date: end_date,
        notes: notes
      )
      guard !med_without_start.valid?
      guard med_without_start.errors[:start_date].present?
      
      # Test 4: Medication WITH all required fields should be accepted
      med_with_all = Medication.new(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: end_date,
        notes: notes
      )
      guard med_with_all.valid?
      guard med_with_all.save
      
      # Verify the medication persists correctly
      retrieved = Medication.find(med_with_all.id)
      guard retrieved.medication_name == medication_name
      guard retrieved.dose == dose
      guard retrieved.start_date == start_date
      
      # Clean up
      med_with_all.destroy
    end
  end

  # Property 13: Active medication filtering
  # Validates: Requirements 3.2
  # For any set of medications for a pet, querying active medications should return
  # only those where end_date is null or in the future, and inactive medications
  # should return only those where end_date is in the past.
  test "property: active medication filtering" do
    pet = pets(:one)
    
    Rantly(100) do
      # Create a mix of active and inactive medications
      num_medications = range(3, 8)
      created_medications = []
      
      num_medications.times do
        # Randomly decide if medication is active or inactive
        is_active = choose(true, false)
        
        start_date = Date.today - range(30, 365).days
        
        # Set end_date based on active status
        end_date = if is_active
          # Active: end_date is nil or in the future
          choose(nil, Date.today + range(1, 180).days)
        else
          # Inactive: end_date is in the past
          Date.today - range(1, 180).days
        end
        
        medication = Medication.create!(
          pet: pet,
          medication_name: choose("Aspirin", "Antibiotics", "Insulin", "Prednisone"),
          dose: choose("5mg", "10mg", "20mg", "1ml"),
          start_date: start_date,
          end_date: end_date
        )
        
        created_medications << { medication: medication, is_active: is_active }
      end
      
      # Query active medications
      active_meds = pet.medications.active.to_a
      
      # Verify all active medications have end_date nil or >= today
      active_meds.each do |med|
        guard med.end_date.nil? || med.end_date >= Date.today
      end
      
      # Query inactive medications
      inactive_meds = pet.medications.inactive.to_a
      
      # Verify all inactive medications have end_date < today
      inactive_meds.each do |med|
        guard med.end_date.present?
        guard med.end_date < Date.today
      end
      
      # Verify that active and inactive sets don't overlap
      active_ids = active_meds.map(&:id)
      inactive_ids = inactive_meds.map(&:id)
      guard (active_ids & inactive_ids).empty?
      
      # Verify that all created medications are in one set or the other
      created_medications.each do |item|
        med_id = item[:medication].id
        if item[:is_active]
          guard active_ids.include?(med_id)
        else
          guard inactive_ids.include?(med_id)
        end
      end
      
      # Clean up
      created_medications.each { |item| item[:medication].destroy }
    end
  end

  # Property 14: Medication status calculation
  # Validates: Requirements 3.3
  # For any medication, the active? method should return true when end_date is
  # null or in the future, and false when end_date is in the past.
  test "property: medication status calculation" do
    pet = pets(:one)
    
    Rantly(100) do
      medication_name = choose("Aspirin", "Antibiotics", "Insulin", "Prednisone")
      dose = choose("5mg", "10mg", "20mg", "1ml")
      start_date = Date.today - range(30, 365).days
      
      # Test 1: Medication with nil end_date should be active
      med_no_end = Medication.create!(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: nil
      )
      guard med_no_end.active? == true
      
      # Test 2: Medication with future end_date should be active
      future_end_date = Date.today + range(1, 180).days
      med_future_end = Medication.create!(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: future_end_date
      )
      guard med_future_end.active? == true
      
      # Test 3: Medication with today as end_date should be active
      med_today_end = Medication.create!(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: Date.today
      )
      guard med_today_end.active? == true
      
      # Test 4: Medication with past end_date should be inactive
      past_end_date = Date.today - range(1, 180).days
      med_past_end = Medication.create!(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: past_end_date
      )
      guard med_past_end.active? == false
      
      # Clean up
      med_no_end.destroy
      med_future_end.destroy
      med_today_end.destroy
      med_past_end.destroy
    end
  end

  # Property 15: Medication-pet association
  # Validates: Requirements 3.4
  # For any medication creation attempt, the medication should be rejected without
  # a pet association and accepted with a valid pet association.
  test "property: medication-pet association" do
    pet = pets(:one)
    
    Rantly(100) do
      # Generate random valid attributes for a medication
      medication_name = choose("Aspirin", "Antibiotics", "Insulin", "Prednisone", "Gabapentin")
      dose = choose("5mg", "10mg", "20mg", "1ml", "2ml")
      start_date = Date.today - range(0, 365).days
      end_date = choose(nil, Date.today + range(1, 365).days)
      notes = choose(nil, "Test notes", "As prescribed", "Important medication")
      
      # Test 1: Medication WITHOUT pet association should be rejected
      med_without_pet = Medication.new(
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: end_date,
        notes: notes
      )
      
      # The medication should be invalid without a pet
      guard !med_without_pet.valid?
      guard med_without_pet.errors[:pet].present?
      
      # Attempting to save should fail
      guard !med_without_pet.save
      
      # Test 2: Medication WITH valid pet association should be accepted
      med_with_pet = Medication.new(
        pet: pet,
        medication_name: medication_name,
        dose: dose,
        start_date: start_date,
        end_date: end_date,
        notes: notes
      )
      
      # The medication should be valid with a pet
      guard med_with_pet.valid?
      
      # Saving should succeed
      guard med_with_pet.save
      
      # Retrieve the medication and verify the pet association is preserved
      retrieved = Medication.find(med_with_pet.id)
      guard retrieved.pet_id == pet.id
      guard retrieved.pet == pet
      
      # Clean up
      med_with_pet.destroy
    end
  end
end
