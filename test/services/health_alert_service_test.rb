require "test_helper"

class HealthAlertServiceTest < ActiveSupport::TestCase
  # Property 7: Low weight alert generation
  # Validates: Requirements 2.1
  # For any health record with weight below the species-appropriate threshold,
  # creating the record should generate a health alert.
  test "property: low weight alert generation" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet with a known species
      species = choose("dog", "cat", "bird")
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: species,
        user: user
      )
      
      # Get the threshold for this species
      thresholds = {
        'dog' => 5.0,
        'cat' => 3.0,
        'bird' => 0.1
      }
      threshold = thresholds[species]
      
      # Generate a weight below the threshold
      # Use a weight that's definitely below threshold (50% to 90% of threshold)
      weight_below = threshold * range(50, 90) / 100.0
      
      # Create a health record with low weight
      health_record = HealthRecord.new(
        pet: pet,
        recorded_on: Date.today,
        weight: weight_below
      )
      
      # Create the service and check for alerts
      service = HealthAlertService.new(health_record)
      
      # Call the private method to check weight threshold
      alert = service.send(:check_weight_threshold)
      
      # Verify that an alert was generated
      guard alert.present?
      guard alert[:type] == 'low_weight'
      guard alert[:message].include?(species)
      guard alert[:severity] == 'high'
      
      # Clean up
      pet.destroy
    end
  end

  # Property 8: Low activity alert generation
  # Validates: Requirements 2.2
  # For any health record with activity_level marked as concerning (very_low),
  # creating the record should generate a health alert.
  test "property: low activity alert generation" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: choose("dog", "cat", "bird"),
        user: user
      )
      
      # Generate random optional attributes
      weight = choose(nil, range(1, 5000) / 100.0)
      
      # Create a health record with very_low activity level
      health_record = HealthRecord.new(
        pet: pet,
        recorded_on: Date.today,
        weight: weight,
        activity_level: 'very_low'
      )
      
      # Create the service and check for alerts
      service = HealthAlertService.new(health_record)
      
      # Call the private method to check activity level
      alert = service.send(:check_activity_level)
      
      # Verify that an alert was generated
      guard alert.present?
      guard alert[:type] == 'low_activity'
      guard alert[:message].include?("Activity level is concerning")
      guard alert[:severity] == 'medium'
      
      # Clean up
      pet.destroy
    end
  end

  # Property 9: Declining trend detection
  # Validates: Requirements 2.5
  # For any sequence of 3 or more consecutive health records where each weight
  # is lower than the previous, the system should generate an escalated health alert.
  test "property: declining trend detection" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: choose("dog", "cat", "bird"),
        user: user
      )
      
      # Generate a sequence of declining weights
      # Start with a reasonable weight and decrease it
      num_records = range(3, 6)
      starting_weight = range(1000, 5000) / 100.0
      
      # Create the first records (at least 2) with declining weights
      # These should be within the recent scope (last 30 days)
      weights = []
      current_weight = starting_weight
      
      (num_records - 1).times do |i|
        # Decrease weight by 5-15%
        current_weight = current_weight * range(85, 95) / 100.0
        weights << current_weight
        
        HealthRecord.create!(
          pet: pet,
          recorded_on: Date.today - (num_records - i).days,
          weight: current_weight
        )
      end
      
      # Now create the final record that should trigger the declining trend alert
      final_weight = current_weight * range(85, 95) / 100.0
      
      final_record = HealthRecord.new(
        pet: pet,
        recorded_on: Date.today,
        weight: final_weight
      )
      
      # Create the service and check for declining trends
      service = HealthAlertService.new(final_record)
      
      # Call the private method to check declining trends
      alert = service.send(:check_declining_trends)
      
      # Verify that a declining trend alert was generated
      guard alert.present?
      guard alert[:type] == 'declining_trend'
      guard alert[:message].include?("declining over recent records")
      guard alert[:severity] == 'high'
      
      # Clean up all records
      pet.health_records.destroy_all
      pet.destroy
    end
  end
end
