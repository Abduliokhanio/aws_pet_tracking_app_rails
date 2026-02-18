require "test_helper"

class VeterinariTest < ActiveSupport::TestCase
  # Property 17: Veterinarian required fields
  # Validates: Requirements 4.1
  # For any veterinarian creation attempt, the veterinarian should be rejected if
  # name is missing, and accepted when name is present.
  test "property: veterinarian required fields" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Generate random optional attributes
      work_history = choose(nil, "5 years at City Clinic", "Experienced in surgery", "General practice")
      years_of_experience = choose(nil, range(0, 40))
      
      # Test 1: Veterinarian WITHOUT name should be rejected
      vet_without_name = Veterinarian.new(
        vet_office: vet_office,
        work_history: work_history,
        years_of_experience: years_of_experience
      )
      guard !vet_without_name.valid?
      guard vet_without_name.errors[:name].present?
      
      # Test 2: Veterinarian WITH name should be accepted
      name = choose("Dr. Smith", "Dr. Johnson", "Dr. Williams", "Dr. Brown", "Dr. Davis")
      
      vet_with_name = Veterinarian.new(
        vet_office: vet_office,
        name: name,
        work_history: work_history,
        years_of_experience: years_of_experience
      )
      guard vet_with_name.valid?
      guard vet_with_name.save
      
      # Verify the veterinarian persists correctly
      retrieved = Veterinarian.find(vet_with_name.id)
      guard retrieved.name == name
      
      # Clean up
      vet_with_name.destroy
    end
  end

  # Property 18: Veterinarian associations
  # Validates: Requirements 4.2
  # For any veterinarian, querying the veterinarian should load the associated
  # vet office and all ratings.
  test "property: veterinarian associations" do
    vet_office = vet_offices(:one)
    user = users(:one)
    
    Rantly(20) do
      # Create a veterinarian
      name = choose("Dr. Smith", "Dr. Johnson", "Dr. Williams")
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: name,
        years_of_experience: range(0, 40)
      )
      
      # Create random number of ratings for this veterinarian
      num_ratings = range(0, 5)
      created_ratings = []
      
      num_ratings.times do |i|
        # Create a user for each rating (to avoid uniqueness constraint)
        test_user = User.create!(
          name: "Test User #{i}-#{rand(10000)}",
          gender: "Other",
          ssn: "#{rand(100000000..999999999)}"
        )
        
        rating = Rating.create!(
          veterinarian: vet,
          user: test_user,
          rating_value: range(1, 5),
          review_text: choose(nil, "Great vet!", "Very caring", "Excellent service")
        )
        created_ratings << rating
      end
      
      # Query the veterinarian and verify associations load
      retrieved_vet = Veterinarian.find(vet.id)
      
      # Verify vet office association
      guard retrieved_vet.vet_office.present?
      guard retrieved_vet.vet_office.id == vet_office.id
      
      # Verify ratings association
      guard retrieved_vet.ratings.count == num_ratings
      
      # Verify all created ratings are accessible
      rating_ids = retrieved_vet.ratings.pluck(:id)
      created_ratings.each do |rating|
        guard rating_ids.include?(rating.id)
      end
      
      # Clean up - destroy ratings first, then users, then vet
      created_ratings.each(&:destroy)
      created_ratings.each { |r| r.user.destroy }
      vet.destroy
    end
  end

  # Property 19: Veterinarian-office association
  # Validates: Requirements 4.3
  # For any veterinarian creation attempt, the veterinarian should be rejected
  # without a vet office association and accepted with a valid vet office association.
  test "property: veterinarian-office association" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Generate random valid attributes
      name = choose("Dr. Smith", "Dr. Johnson", "Dr. Williams", "Dr. Brown")
      work_history = choose(nil, "5 years experience", "Specialist in surgery")
      years_of_experience = choose(nil, range(0, 40))
      
      # Test 1: Veterinarian WITHOUT vet office should be rejected
      vet_without_office = Veterinarian.new(
        name: name,
        work_history: work_history,
        years_of_experience: years_of_experience
      )
      
      guard !vet_without_office.valid?
      guard vet_without_office.errors[:vet_office].present?
      guard !vet_without_office.save
      
      # Test 2: Veterinarian WITH vet office should be accepted
      vet_with_office = Veterinarian.new(
        vet_office: vet_office,
        name: name,
        work_history: work_history,
        years_of_experience: years_of_experience
      )
      
      guard vet_with_office.valid?
      guard vet_with_office.save
      
      # Verify the association is preserved
      retrieved = Veterinarian.find(vet_with_office.id)
      guard retrieved.vet_office_id == vet_office.id
      guard retrieved.vet_office == vet_office
      
      # Clean up
      vet_with_office.destroy
    end
  end

  # Property 20: Office change preservation
  # Validates: Requirements 4.4
  # For any veterinarian, changing the vet_office_id should update the association
  # without deleting historical ratings or other associated data.
  test "property: office change preservation" do
    vet_office_1 = vet_offices(:one)
    vet_office_2 = vet_offices(:two)
    
    Rantly(20) do
      # Create a veterinarian at office 1
      vet = Veterinarian.create!(
        vet_office: vet_office_1,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Create some ratings for this veterinarian
      num_ratings = range(1, 3)
      created_ratings = []
      
      num_ratings.times do |i|
        test_user = User.create!(
          name: "Test User #{i}-#{rand(10000)}",
          gender: "Other",
          ssn: "#{rand(100000000..999999999)}"
        )
        
        rating = Rating.create!(
          veterinarian: vet,
          user: test_user,
          rating_value: range(1, 5),
          review_text: "Great vet!"
        )
        created_ratings << rating
      end
      
      # Store original rating IDs
      original_rating_ids = created_ratings.map(&:id)
      
      # Change the vet office
      vet.update!(vet_office: vet_office_2)
      
      # Reload and verify office changed
      vet.reload
      guard vet.vet_office_id == vet_office_2.id
      
      # Verify ratings are still present and unchanged
      guard vet.ratings.count == num_ratings
      
      current_rating_ids = vet.ratings.pluck(:id)
      original_rating_ids.each do |rating_id|
        guard current_rating_ids.include?(rating_id)
      end
      
      # Verify each rating still exists in database
      original_rating_ids.each do |rating_id|
        guard Rating.exists?(rating_id)
      end
      
      # Clean up - destroy ratings first, then users, then vet
      created_ratings.each(&:destroy)
      created_ratings.each { |r| r.user.destroy }
      vet.destroy
    end
  end

  # Property 21: Shared veterinarian access
  # Validates: Requirements 4.5
  # For any veterinarian, multiple users should be able to create ratings for
  # the same veterinarian.
  test "property: shared veterinarian access" do
    vet_office = vet_offices(:one)
    
    Rantly(20) do
      # Create a veterinarian
      vet = Veterinarian.create!(
        vet_office: vet_office,
        name: choose("Dr. Smith", "Dr. Johnson", "Dr. Williams"),
        years_of_experience: range(0, 40)
      )
      
      # Create multiple users and have each rate the same veterinarian
      num_users = range(2, 5)
      created_users = []
      created_ratings = []
      
      num_users.times do |i|
        user = User.create!(
          name: "User #{i}-#{rand(10000)}",
          gender: choose("Male", "Female", "Other"),
          ssn: "#{rand(100000000..999999999)}"
        )
        created_users << user
        
        rating = Rating.create!(
          veterinarian: vet,
          user: user,
          rating_value: range(1, 5),
          review_text: choose("Excellent", "Very good", "Great service")
        )
        created_ratings << rating
      end
      
      # Verify all ratings were created successfully
      guard vet.ratings.count == num_users
      
      # Verify each user has their rating
      created_users.each do |user|
        user_rating = vet.ratings.find_by(user: user)
        guard user_rating.present?
      end
      
      # Verify all ratings belong to the same veterinarian
      created_ratings.each do |rating|
        guard rating.veterinarian_id == vet.id
      end
      
      # Clean up - destroy ratings first, then users, then vet
      created_ratings.each(&:destroy)
      created_users.each(&:destroy)
      vet.destroy
    end
  end
end
