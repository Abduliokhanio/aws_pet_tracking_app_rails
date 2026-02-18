require "test_helper"

class RatingTest < ActiveSupport::TestCase
  # Property 22: Rating required fields
  # Validates: Requirements 5.1
  # For any rating creation attempt, the rating should be rejected if rating_value
  # is missing, and accepted when rating_value is present.
  test "property: rating required fields" do
    vet_office = vet_offices(:one)
    user = users(:one)
    
    Rantly(20) do
      # Create a veterinarian for the rating
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Generate optional attributes
      review_text = choose(nil, "Great vet!", "Very caring", "Excellent service")
      
      # Test 1: Rating WITHOUT rating_value should be rejected
      rating_without_value = Rating.new(
        veterinarian: vet,
        user: user,
        review_text: review_text
      )
      guard !rating_without_value.valid?
      guard rating_without_value.errors[:rating_value].present?
      
      # Test 2: Rating WITH rating_value should be accepted
      rating_value = range(1, 5)
      
      rating_with_value = Rating.new(
        veterinarian: vet,
        user: user,
        rating_value: rating_value,
        review_text: review_text
      )
      guard rating_with_value.valid?
      guard rating_with_value.save
      
      # Verify the rating persists correctly
      retrieved = Rating.find(rating_with_value.id)
      guard retrieved.rating_value == rating_value
      
      # Clean up
      rating_with_value.destroy
      vet.destroy
    end
  end

  # Property 23: Average rating calculation
  # Validates: Requirements 5.2
  # For any veterinarian with multiple ratings, the average_rating method should
  # return the arithmetic mean of all rating_value fields rounded to 2 decimal places.
  test "property: average rating calculation" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Create a veterinarian
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Create multiple ratings with known values
      num_ratings = range(1, 10)
      rating_values = []
      created_users = []
      
      num_ratings.times do |i|
        # Create a unique user for each rating
        user = User.create!(
          name: "User #{i}-#{rand(10000)}",
          gender: "Other",
          ssn: "#{rand(100000000..999999999)}"
        )
        created_users << user
        
        rating_value = range(1, 5)
        rating_values << rating_value
        
        Rating.create!(
          veterinarian: vet,
          user: user,
          rating_value: rating_value,
          review_text: "Test review"
        )
      end
      
      # Calculate expected average
      expected_average = (rating_values.sum.to_f / rating_values.size).round(2)
      
      # Get actual average from method
      actual_average = vet.average_rating
      
      # Verify the average is correct
      guard actual_average == expected_average
      
      # Verify it's rounded to 2 decimal places
      guard actual_average.to_s.split('.').last.length <= 2
      
      # Clean up
      created_users.each(&:destroy)
      vet.destroy
    end
  end

  # Property 24: Rating value constraints
  # Validates: Requirements 5.3
  # For any rating creation attempt, the rating should be rejected if rating_value
  # is outside the range 1-5, and accepted if within the range.
  test "property: rating value constraints" do
    vet_office = vet_offices(:one)
    user = users(:one)
    
    Rantly(20) do
      # Create a veterinarian
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Test 1: Rating with value < 1 should be rejected
      invalid_low_value = choose(0, -1, -5, -100)
      rating_too_low = Rating.new(
        veterinarian: vet,
        user: user,
        rating_value: invalid_low_value
      )
      guard !rating_too_low.valid?
      guard rating_too_low.errors[:rating_value].present?
      
      # Test 2: Rating with value > 5 should be rejected
      invalid_high_value = choose(6, 7, 10, 100)
      rating_too_high = Rating.new(
        veterinarian: vet,
        user: user,
        rating_value: invalid_high_value
      )
      guard !rating_too_high.valid?
      guard rating_too_high.errors[:rating_value].present?
      
      # Test 3: Rating with value in range 1-5 should be accepted
      valid_value = range(1, 5)
      rating_valid = Rating.new(
        veterinarian: vet,
        user: user,
        rating_value: valid_value
      )
      guard rating_valid.valid?
      guard rating_valid.save
      
      # Verify the rating persists correctly
      retrieved = Rating.find(rating_valid.id)
      guard retrieved.rating_value == valid_value
      guard retrieved.rating_value >= 1
      guard retrieved.rating_value <= 5
      
      # Clean up
      rating_valid.destroy
      vet.destroy
    end
  end

  # Property 25: One rating per user per veterinarian
  # Validates: Requirements 5.4, 5.5
  # For any user and veterinarian pair, attempting to create a second rating should
  # be rejected, and updating the existing rating should succeed.
  test "property: one rating per user per veterinarian" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Create a veterinarian
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Create a user
      user = User.create!(
        name: "Test User #{rand(10000)}",
        gender: "Other",
        ssn: "#{rand(100000000..999999999)}"
      )
      
      # Create first rating
      first_rating_value = range(1, 5)
      first_rating = Rating.create!(
        veterinarian: vet,
        user: user,
        rating_value: first_rating_value,
        review_text: "First review"
      )
      
      # Test 1: Attempting to create a second rating should be rejected
      second_rating_value = range(1, 5)
      second_rating = Rating.new(
        veterinarian: vet,
        user: user,
        rating_value: second_rating_value,
        review_text: "Second review"
      )
      
      guard !second_rating.valid?
      guard second_rating.errors[:user_id].present?
      guard !second_rating.save
      
      # Verify only one rating exists
      guard vet.ratings.where(user: user).count == 1
      
      # Test 2: Updating the existing rating should succeed
      new_rating_value = range(1, 5)
      new_review_text = "Updated review"
      
      first_rating.rating_value = new_rating_value
      first_rating.review_text = new_review_text
      
      guard first_rating.valid?
      guard first_rating.save
      
      # Verify the update persisted
      first_rating.reload
      guard first_rating.rating_value == new_rating_value
      guard first_rating.review_text == new_review_text
      
      # Verify still only one rating exists
      guard vet.ratings.where(user: user).count == 1
      
      # Test 3: Different user should be able to rate the same veterinarian
      another_user = User.create!(
        name: "Another User #{rand(10000)}",
        gender: "Other",
        ssn: "#{rand(100000000..999999999)}"
      )
      
      another_rating = Rating.create!(
        veterinarian: vet,
        user: another_user,
        rating_value: range(1, 5),
        review_text: "Another review"
      )
      
      guard another_rating.persisted?
      guard vet.ratings.count == 2
      
      # Clean up
      another_user.destroy
      user.destroy
      vet.destroy
    end
  end
end
