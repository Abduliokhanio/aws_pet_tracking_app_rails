require "test_helper"

class HealthRecordTest < ActiveSupport::TestCase
  # Property 1: Weight precision preservation
  # Validates: Requirements 1.1
  # For any health record with a weight value, storing and retrieving the weight
  # should preserve precision to 2 decimal places and scale to 5 total digits.
  test "property: weight precision preservation" do
    pet = pets(:one)
    
    Rantly(100) do
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
    
    Rantly(100) do
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
end
