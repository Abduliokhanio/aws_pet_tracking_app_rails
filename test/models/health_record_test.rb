require "test_helper"

class HealthRecordTest < ActiveSupport::TestCase
  # Property 1: Weight precision preservation
  # Validates: Requirements 1.1
  # For any health record with a weight value, storing and retrieving the weight
  # should preserve precision to 2 decimal places and scale to 5 total digits.
  test "property: weight precision preservation" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate random weight with up to 2 decimal places
      # Range: 0.01 to 999.99 (5 digits total, 2 decimal places)
      weight = range(1, 99999) / 100.0
      
      # Create health record with the generated weight
      health_record = HealthRecord.create!(
        pet: pet,
        recorded_on: Date.today,
        weight: weight
      )
      
      # Retrieve the record from database
      retrieved_record = HealthRecord.find(health_record.id)
      
      # Assert that the weight is preserved with 2 decimal places precision
      # The stored value should match the original value rounded to 2 decimal places
      expected_weight = weight.round(2)
      actual_weight = retrieved_record.weight.to_f
      
      # Verify precision is preserved
      guard actual_weight == expected_weight
      
      # Verify the weight has at most 2 decimal places
      decimal_places = actual_weight.to_s.split('.').last.length
      guard decimal_places <= 2
      
      # Clean up
      health_record.destroy
    end
  end

  # Property 2: Required date validation
  # Validates: Requirements 1.2
  # For any health record creation attempt, the record should be rejected if
  # recorded_on is missing, and accepted if recorded_on is present.
  test "property: required date validation" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate random optional attributes
      weight = choose(nil, range(1, 99999) / 100.0)
      mood = choose(nil, %w[happy sad anxious playful lethargic])
      activity_level = choose(nil, %w[very_high high normal low very_low])
      food_intake = choose(nil, %w[excellent good fair poor none])
      status = choose(nil, %w[excellent good fair poor critical])
      notes = choose(nil, string)
      
      # Test 1: Record WITHOUT recorded_on should be rejected
      record_without_date = HealthRecord.new(
        pet: pet,
        weight: weight,
        mood: mood,
        activity_level: activity_level,
        food_intake: food_intake,
        status: status,
        notes: notes
      )
      
      guard !record_without_date.valid?
      guard record_without_date.errors[:recorded_on].present?
      
      # Test 2: Record WITH recorded_on should be accepted
      # Generate a random date within a reasonable range
      days_offset = range(-365, 365)
      recorded_date = Date.today + days_offset.days
      
      record_with_date = HealthRecord.new(
        pet: pet,
        recorded_on: recorded_date,
        weight: weight,
        mood: mood,
        activity_level: activity_level,
        food_intake: food_intake,
        status: status,
        notes: notes
      )
      
      guard record_with_date.valid?
      
      # If we save it, verify it persists correctly
      if record_with_date.save
        retrieved = HealthRecord.find(record_with_date.id)
        guard retrieved.recorded_on == recorded_date
        record_with_date.destroy
      end
    end
  end

  # Property 3: Optional fields acceptance
  # Validates: Requirements 1.3
  # For any health record, creating it with or without mood, activity_level,
  # food_intake, medication_name, medication_dose, status, or notes should succeed.
  test "property: optional fields acceptance" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate a valid recorded_on date (required field)
      days_offset = range(-365, 365)
      recorded_date = Date.today + days_offset.days
      
      # Generate random weight (optional but commonly used)
      weight = choose(nil, range(1, 99999) / 100.0)
      
      # Generate random values for each optional field
      # Each field can be nil or a valid value
      mood = choose(nil, "happy", "sad", "anxious", "playful", "lethargic")
      activity_level = choose(nil, "very_high", "high", "normal", "low", "very_low")
      food_intake = choose(nil, "excellent", "good", "fair", "poor", "none")
      medication_name = choose(nil, "Aspirin", "Antibiotics", "Insulin", "Prednisone")
      medication_dose = choose(nil, "5mg", "10mg", "20mg", "1ml", "2ml")
      # status has validation - must be one of the allowed values or nil
      status = choose(nil, "excellent", "good", "fair", "poor", "critical")
      notes = choose(nil, "Regular checkup", "Seems healthy", "No issues", "Ate well today")
      
      # Create health record with random combination of optional fields
      health_record = HealthRecord.new(
        pet: pet,
        recorded_on: recorded_date,
        weight: weight,
        mood: mood,
        activity_level: activity_level,
        food_intake: food_intake,
        medication_name: medication_name,
        medication_dose: medication_dose,
        status: status,
        notes: notes
      )
      
      # The record should be valid regardless of which optional fields are present
      guard health_record.valid?
      
      # Save the record and verify it persists correctly
      guard health_record.save
      
      # Retrieve the record and verify all fields are preserved
      retrieved = HealthRecord.find(health_record.id)
      guard retrieved.recorded_on == recorded_date
      
      # Compare weight carefully - both might be nil
      if weight.nil?
        guard retrieved.weight.nil?
      else
        guard retrieved.weight.present?
        guard (retrieved.weight.to_f - weight.to_f).abs < 0.01
      end
      
      guard retrieved.mood == mood
      guard retrieved.activity_level == activity_level
      guard retrieved.food_intake == food_intake
      guard retrieved.medication_name == medication_name
      guard retrieved.medication_dose == medication_dose
      guard retrieved.status == status
      guard retrieved.notes == notes
      
      # Clean up
      health_record.destroy
    end
  end

  # Property 4: Chronological ordering
  # Validates: Requirements 1.4
  # For any set of health records for a pet, querying them should return records
  # ordered by recorded_on date in descending order.
  test "property: chronological ordering" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate a random number of health records (3 to 10)
      num_records = range(3, 10)
      
      # Generate random dates for the records
      # Use a range of dates to ensure variety
      dates = Array.new(num_records) do
        days_offset = range(-730, 0) # Up to 2 years in the past
        Date.today + days_offset.days
      end
      
      # Create health records with the generated dates
      created_records = dates.map do |date|
        HealthRecord.create!(
          pet: pet,
          recorded_on: date,
          weight: range(1, 5000) / 100.0 # Random weight
        )
      end
      
      # Query records using the chronological scope
      queried_records = pet.health_records.chronological.to_a
      
      # Verify that the records are ordered by recorded_on in descending order
      # This means each record's date should be >= the next record's date
      queried_records.each_cons(2) do |current, next_record|
        guard current.recorded_on >= next_record.recorded_on
      end
      
      # Verify that all created records are present in the query result
      guard queried_records.size >= num_records
      
      # Verify that the dates in the result match our created dates (in descending order)
      expected_dates = dates.sort.reverse
      actual_dates = queried_records.first(num_records).map(&:recorded_on)
      
      # Check that the ordering is correct
      actual_dates.each_cons(2) do |current_date, next_date|
        guard current_date >= next_date
      end
      
      # Clean up
      created_records.each(&:destroy)
    end
  end

  # Property 5: Recorded date immutability
  # Validates: Requirements 1.5
  # For any health record, updating any field except recorded_on should preserve
  # the original recorded_on value.
  test "property: recorded date immutability" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate initial recorded_on date
      initial_days_offset = range(-365, 0)
      initial_recorded_on = Date.today + initial_days_offset.days
      
      # Create a health record with initial values
      health_record = HealthRecord.create!(
        pet: pet,
        recorded_on: initial_recorded_on,
        weight: range(1, 5000) / 100.0,
        mood: choose("happy", "sad", "anxious", "playful", "lethargic"),
        activity_level: choose("very_high", "high", "normal", "low", "very_low"),
        food_intake: choose("excellent", "good", "fair", "poor", "none"),
        medication_name: choose("Aspirin", "Antibiotics", "Insulin"),
        medication_dose: choose("5mg", "10mg", "20mg"),
        status: choose("excellent", "good", "fair", "poor", "critical"),
        notes: "Initial notes"
      )
      
      # Store the original recorded_on value
      original_recorded_on = health_record.recorded_on
      
      # Generate new values for all updatable fields (except recorded_on)
      new_weight = range(1, 5000) / 100.0
      new_mood = choose("happy", "sad", "anxious", "playful", "lethargic")
      new_activity_level = choose("very_high", "high", "normal", "low", "very_low")
      new_food_intake = choose("excellent", "good", "fair", "poor", "none")
      new_medication_name = choose("Prednisone", "Gabapentin", "Tramadol")
      new_medication_dose = choose("1ml", "2ml", "15mg")
      new_status = choose("excellent", "good", "fair", "poor", "critical")
      new_notes = "Updated notes"
      
      # Update the health record with new values for all fields except recorded_on
      health_record.update!(
        weight: new_weight,
        mood: new_mood,
        activity_level: new_activity_level,
        food_intake: new_food_intake,
        medication_name: new_medication_name,
        medication_dose: new_medication_dose,
        status: new_status,
        notes: new_notes
      )
      
      # Reload the record from the database
      health_record.reload
      
      # Verify that recorded_on has NOT changed
      guard health_record.recorded_on == original_recorded_on
      
      # Verify that other fields HAVE changed
      guard health_record.weight.to_f == new_weight
      guard health_record.mood == new_mood
      guard health_record.activity_level == new_activity_level
      guard health_record.food_intake == new_food_intake
      guard health_record.medication_name == new_medication_name
      guard health_record.medication_dose == new_medication_dose
      guard health_record.status == new_status
      guard health_record.notes == new_notes
      
      # Clean up
      health_record.destroy
    end
  end

  # Property 6: Pet association requirement
  # Validates: Requirements 1.6
  # For any health record creation attempt, the record should be rejected without
  # a pet association and accepted with a valid pet association.
  test "property: pet association requirement" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate random valid attributes for a health record
      days_offset = range(-365, 365)
      recorded_date = Date.today + days_offset.days
      weight = choose(nil, range(1, 99999) / 100.0)
      mood = choose(nil, "happy", "sad", "anxious", "playful", "lethargic")
      activity_level = choose(nil, "very_high", "high", "normal", "low", "very_low")
      food_intake = choose(nil, "excellent", "good", "fair", "poor", "none")
      status = choose(nil, "excellent", "good", "fair", "poor", "critical")
      notes = choose(nil, "Test notes", "Regular checkup", "No issues")
      
      # Test 1: Record WITHOUT pet association should be rejected
      record_without_pet = HealthRecord.new(
        recorded_on: recorded_date,
        weight: weight,
        mood: mood,
        activity_level: activity_level,
        food_intake: food_intake,
        status: status,
        notes: notes
      )
      
      # The record should be invalid without a pet
      guard !record_without_pet.valid?
      guard record_without_pet.errors[:pet].present?
      
      # Attempting to save should fail
      guard !record_without_pet.save
      
      # Test 2: Record WITH valid pet association should be accepted
      record_with_pet = HealthRecord.new(
        pet: pet,
        recorded_on: recorded_date,
        weight: weight,
        mood: mood,
        activity_level: activity_level,
        food_intake: food_intake,
        status: status,
        notes: notes
      )
      
      # The record should be valid with a pet
      guard record_with_pet.valid?
      
      # Saving should succeed
      guard record_with_pet.save
      
      # Retrieve the record and verify the pet association is preserved
      retrieved = HealthRecord.find(record_with_pet.id)
      guard retrieved.pet_id == pet.id
      guard retrieved.pet == pet
      
      # Clean up
      record_with_pet.destroy
    end
  end
end
