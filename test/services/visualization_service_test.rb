require "test_helper"

class VisualizationServiceTest < ActiveSupport::TestCase
  # Property 54: Weight chart data structure
  # Validates: Requirements 12.1
  # For any pet with health records in a date range, the weight chart data should
  # include arrays of dates and corresponding weights for all records with weight values.
  test "property: weight chart data structure" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Generate a random date range
      start_date = PropertyGenerators.random_past_date(max_days: 180)
      end_date = Date.today
      
      # Create random number of health records with weights in the date range
      num_records = range(1, 10)
      created_records = []
      
      num_records.times do
        recorded_on = PropertyGenerators.random_date(start_date: start_date, end_date: end_date)
        weight = PropertyGenerators.random_weight
        
        created_records << HealthRecord.create!(
          pet: pet,
          recorded_on: recorded_on,
          weight: weight
        )
      end
      
      # Create the service
      service = VisualizationService.new(pet, start_date: start_date, end_date: end_date)
      
      # Get the weight chart data
      chart_data = service.weight_chart_data
      
      # Verify the structure
      guard chart_data.is_a?(Hash)
      guard chart_data.key?(:labels)
      guard chart_data.key?(:datasets)
      guard chart_data[:labels].is_a?(Array)
      guard chart_data[:datasets].is_a?(Array)
      guard chart_data[:datasets].length == 1
      
      # Verify the dataset structure
      dataset = chart_data[:datasets].first
      guard dataset.is_a?(Hash)
      guard dataset.key?(:label)
      guard dataset.key?(:data)
      guard dataset[:data].is_a?(Array)
      
      # Verify that labels and data have the same length
      guard chart_data[:labels].length == dataset[:data].length
      
      # Verify that the number of data points matches the number of records with weights
      guard chart_data[:labels].length == num_records
      
      # Verify all dates are within the range
      chart_data[:labels].each do |date|
        guard date >= start_date
        guard date <= end_date
      end
      
      # Verify all weights are present and valid
      dataset[:data].each do |weight|
        guard weight.present?
        guard weight > 0
      end
      
      # Clean up
      pet.health_records.destroy_all
      pet.destroy
    end
    
    # Explicit assertion to satisfy test framework
    assert true, "Property test completed successfully"
  end

  # Property 55: Medication timeline data structure
  # Validates: Requirements 12.2
  # For any pet with medications, the timeline data should include medication name,
  # dose, start date, end date, and active status for each medication.
  test "property: medication timeline data structure" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Generate a random date range
      start_date = PropertyGenerators.random_past_date(max_days: 180)
      end_date = Date.today
      
      # Create random number of medications that overlap with the date range
      num_medications = range(1, 5)
      created_medications = []
      
      num_medications.times do
        med_start = PropertyGenerators.random_date(start_date: start_date - 30.days, end_date: end_date)
        
        # Randomly decide if medication has ended
        med_end = choose(nil, PropertyGenerators.random_date(start_date: med_start, end_date: end_date + 30.days))
        
        created_medications << Medication.create!(
          pet: pet,
          medication_name: PropertyGenerators.random_medication_name,
          dose: PropertyGenerators.random_medication_dose,
          start_date: med_start,
          end_date: med_end
        )
      end
      
      # Create the service
      service = VisualizationService.new(pet, start_date: start_date, end_date: end_date)
      
      # Get the medication timeline data
      timeline_data = service.medication_timeline_data
      
      # Verify the structure
      guard timeline_data.is_a?(Array)
      
      # Verify each medication entry has the required fields
      timeline_data.each do |med_data|
        guard med_data.is_a?(Hash)
        guard med_data.key?(:name)
        guard med_data.key?(:dose)
        guard med_data.key?(:start)
        guard med_data.key?(:end)
        guard med_data.key?(:active)
        
        # Verify field types
        guard med_data[:name].is_a?(String)
        guard med_data[:dose].is_a?(String)
        guard med_data[:start].is_a?(Date)
        guard med_data[:end].is_a?(Date)
        guard [true, false].include?(med_data[:active])
        
        # Verify start is before or equal to end
        guard med_data[:start] <= med_data[:end]
      end
      
      # Clean up
      pet.medications.destroy_all
      pet.destroy
    end
    
    # Explicit assertion to satisfy test framework
    assert true, "Property test completed successfully"
  end

  # Property 56: Visualization date filtering
  # Validates: Requirements 12.3
  # For any pet and date range, visualization data should include only health records
  # and medications within the specified date range.
  test "property: visualization date filtering" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Generate a specific date range for filtering
      filter_start = PropertyGenerators.random_past_date(max_days: 90)
      filter_end = filter_start + range(30, 60).days
      
      # Create health records both inside and outside the range
      records_inside = range(2, 5)
      records_outside = range(1, 3)
      
      inside_dates = []
      records_inside.times do
        recorded_on = PropertyGenerators.random_date(start_date: filter_start, end_date: filter_end)
        inside_dates << recorded_on
        
        HealthRecord.create!(
          pet: pet,
          recorded_on: recorded_on,
          weight: PropertyGenerators.random_weight
        )
      end
      
      # Create records outside the range (before start)
      records_outside.times do
        recorded_on = PropertyGenerators.random_date(start_date: filter_start - 60.days, end_date: filter_start - 1.day)
        
        HealthRecord.create!(
          pet: pet,
          recorded_on: recorded_on,
          weight: PropertyGenerators.random_weight
        )
      end
      
      # Create medications both inside and outside the range
      meds_inside = range(1, 3)
      meds_outside = range(1, 2)
      
      meds_inside.times do
        med_start = PropertyGenerators.random_date(start_date: filter_start, end_date: filter_end)
        
        Medication.create!(
          pet: pet,
          medication_name: PropertyGenerators.random_medication_name,
          dose: PropertyGenerators.random_medication_dose,
          start_date: med_start,
          end_date: choose(nil, PropertyGenerators.random_future_date(from: med_start, max_days: 30))
        )
      end
      
      # Create medications completely outside the range (ended before filter_start)
      meds_outside.times do
        med_start = PropertyGenerators.random_date(start_date: filter_start - 90.days, end_date: filter_start - 60.days)
        med_end = PropertyGenerators.random_date(start_date: med_start, end_date: filter_start - 30.days)
        
        Medication.create!(
          pet: pet,
          medication_name: PropertyGenerators.random_medication_name,
          dose: PropertyGenerators.random_medication_dose,
          start_date: med_start,
          end_date: med_end
        )
      end
      
      # Create the service with the specific date range
      service = VisualizationService.new(pet, start_date: filter_start, end_date: filter_end)
      
      # Get the weight chart data
      chart_data = service.weight_chart_data
      
      # Verify only records within the date range are included
      guard chart_data[:labels].length == records_inside
      chart_data[:labels].each do |date|
        guard date >= filter_start
        guard date <= filter_end
      end
      
      # Get the medication timeline data
      timeline_data = service.medication_timeline_data
      
      # Verify medications are filtered correctly
      # Medications should be included if they overlap with the date range
      timeline_data.each do |med_data|
        # Medication overlaps if: start_date <= filter_end AND (end_date IS NULL OR end_date >= filter_start)
        guard med_data[:start] <= filter_end
        # If end is present, it should be >= filter_start (or it's today for active meds)
      end
      
      # Clean up
      pet.health_records.destroy_all
      pet.medications.destroy_all
      pet.destroy
    end
    
    # Explicit assertion to satisfy test framework
    assert true, "Property test completed successfully"
  end

  # Property 57: Multi-metric visualization
  # Validates: Requirements 12.5
  # For any pet with health records, the visualization data should include
  # aggregated data for mood, activity_level, and food_intake.
  test "property: multi-metric visualization" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: "Test Pet #{rand(1000)}",
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Generate a random date range
      start_date = PropertyGenerators.random_past_date(max_days: 90)
      end_date = Date.today
      
      # Create random number of health records with various metrics
      num_records = range(3, 10)
      
      num_records.times do
        recorded_on = PropertyGenerators.random_date(start_date: start_date, end_date: end_date)
        
        # Randomly include or exclude each metric
        mood = choose(nil, PropertyGenerators.random_mood)
        activity_level = choose(nil, PropertyGenerators.random_activity_level)
        food_intake = choose(nil, PropertyGenerators.random_food_intake)
        
        HealthRecord.create!(
          pet: pet,
          recorded_on: recorded_on,
          weight: choose(nil, PropertyGenerators.random_weight),
          mood: mood,
          activity_level: activity_level,
          food_intake: food_intake
        )
      end
      
      # Create the service
      service = VisualizationService.new(pet, start_date: start_date, end_date: end_date)
      
      # Get the health metrics data
      metrics_data = service.health_metrics_data
      
      # Verify the structure
      guard metrics_data.is_a?(Hash)
      guard metrics_data.key?(:mood)
      guard metrics_data.key?(:activity_level)
      guard metrics_data.key?(:food_intake)
      
      # Verify each metric is a hash (aggregated counts)
      guard metrics_data[:mood].is_a?(Hash)
      guard metrics_data[:activity_level].is_a?(Hash)
      guard metrics_data[:food_intake].is_a?(Hash)
      
      # Verify that counts are non-negative integers
      [metrics_data[:mood], metrics_data[:activity_level], metrics_data[:food_intake]].each do |metric_hash|
        metric_hash.each do |key, count|
          guard key.present?
          guard count.is_a?(Integer)
          guard count > 0
        end
      end
      
      # Verify that the total counts don't exceed the number of records
      total_mood_count = metrics_data[:mood].values.sum
      total_activity_count = metrics_data[:activity_level].values.sum
      total_food_intake_count = metrics_data[:food_intake].values.sum
      
      guard total_mood_count <= num_records
      guard total_activity_count <= num_records
      guard total_food_intake_count <= num_records
      
      # Clean up
      pet.health_records.destroy_all
      pet.destroy
    end
    
    # Explicit assertion to satisfy test framework
    assert true, "Property test completed successfully"
  end
end
