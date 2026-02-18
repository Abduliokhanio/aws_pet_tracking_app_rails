require "test_helper"

class PetHealthThresholdTest < ActiveSupport::TestCase
  # **Validates: Requirements 2.4**
  # Property 10: Custom threshold persistence
  test "custom thresholds persist and retrieve correctly" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    
    Rantly(20) do
      threshold_type = choose('min_weight', 'max_weight', 'min_activity', 'alert_sensitivity')
      threshold_value = range(1, 10000) / 100.0  # 0.01 to 100.00
      
      # Create threshold
      threshold = pet.pet_health_thresholds.create!(
        threshold_type: threshold_type,
        threshold_value: threshold_value
      )
      
      # Retrieve and verify
      retrieved = pet.pet_health_thresholds.find_by(threshold_type: threshold_type)
      guard retrieved.threshold_value.to_f == threshold_value.round(2)
      
      # Clean up for next iteration
      threshold.destroy
    end
  end
  
  # **Validates: Requirements 10.4**
  # Property 47: Alert sensitivity configuration
  test "alert sensitivity levels persist and retrieve correctly" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    
    Rantly(20) do
      sensitivity_level = range(1, 5)
      
      # Set sensitivity
      threshold = pet.pet_health_thresholds.find_or_initialize_by(threshold_type: 'alert_sensitivity')
      threshold.threshold_value = sensitivity_level
      threshold.save!
      
      # Retrieve and verify
      retrieved = pet.pet_health_thresholds.find_by(threshold_type: 'alert_sensitivity')
      guard retrieved.threshold_value.to_i == sensitivity_level
      
      # Clean up
      threshold.destroy
    end
  end
  
  # Unit test: Validation tests
  test "requires threshold_type" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    threshold = pet.pet_health_thresholds.build(threshold_value: 5.0)
    assert_not threshold.valid?
    assert_includes threshold.errors[:threshold_type], "can't be blank"
  end
  
  test "requires threshold_value" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    threshold = pet.pet_health_thresholds.build(threshold_type: 'min_weight')
    assert_not threshold.valid?
    assert_includes threshold.errors[:threshold_value], "can't be blank"
  end
  
  test "threshold_value must be greater than 0" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    threshold = pet.pet_health_thresholds.build(threshold_type: 'min_weight', threshold_value: 0)
    assert_not threshold.valid?
    assert_includes threshold.errors[:threshold_value], "must be greater than 0"
  end
  
  test "threshold_type must be valid" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    threshold = pet.pet_health_thresholds.build(threshold_type: 'invalid_type', threshold_value: 5.0)
    assert_not threshold.valid?
    assert_includes threshold.errors[:threshold_type], "is not included in the list"
  end
  
  test "enforces uniqueness of threshold_type per pet" do
    pet = Pet.create!(name: "Test Pet", species: "dog", user: users(:one))
    pet.pet_health_thresholds.create!(threshold_type: 'min_weight', threshold_value: 5.0)
    
    duplicate = pet.pet_health_thresholds.build(threshold_type: 'min_weight', threshold_value: 10.0)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:threshold_type], "has already been taken"
  end
end
