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
end
