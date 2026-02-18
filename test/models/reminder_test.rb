require "test_helper"

class ReminderTest < ActiveSupport::TestCase
  # Property 40: Reminder required fields
  # Validates: Requirements 9.1
  # For any reminder creation attempt, the reminder should be rejected if
  # reminder_type, scheduled_date, or title is missing, and accepted when all are present.
  test "property: reminder required fields" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate random optional attributes
      description = choose(nil, "Vet checkup", "Give medication", "Grooming appointment", "Regular care")
      
      # Generate valid values for required fields
      reminder_type = choose("vet_appointment", "medication", "grooming", "custom")
      scheduled_date = Date.today + range(-30, 180).days
      title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup", "Vaccination")
      
      # Test 1: Reminder WITHOUT reminder_type should be rejected
      reminder_without_type = Reminder.new(
        pet: pet,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      guard !reminder_without_type.valid?
      guard reminder_without_type.errors[:reminder_type].present?
      
      # Test 2: Reminder WITHOUT scheduled_date should be rejected
      reminder_without_date = Reminder.new(
        pet: pet,
        reminder_type: reminder_type,
        title: title,
        description: description
      )
      guard !reminder_without_date.valid?
      guard reminder_without_date.errors[:scheduled_date].present?
      
      # Test 3: Reminder WITHOUT title should be rejected
      reminder_without_title = Reminder.new(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: scheduled_date,
        description: description
      )
      guard !reminder_without_title.valid?
      guard reminder_without_title.errors[:title].present?
      
      # Test 4: Reminder WITH all required fields should be accepted
      reminder_with_all = Reminder.new(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      guard reminder_with_all.valid?
      guard reminder_with_all.save
      
      # Verify the reminder persists correctly
      retrieved = Reminder.find(reminder_with_all.id)
      guard retrieved.reminder_type == reminder_type
      guard retrieved.scheduled_date == scheduled_date
      guard retrieved.title == title
      
      # Clean up
      reminder_with_all.destroy
    end
  end

  # Property 41: Due reminder detection
  # Validates: Requirements 9.2
  # For any reminder, the due? method should return true when scheduled_date is
  # today or in the past and completed_at is nil, and false otherwise.
  test "property: due reminder detection" do
    pet = pets(:one)
    
    Rantly(20) do
      title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup")
      reminder_type = choose("vet_appointment", "medication", "grooming", "custom")
      
      # Test 1: Reminder with past scheduled_date and nil completed_at should be due
      past_date = Date.today - range(1, 30).days
      reminder_past = Reminder.create!(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: past_date,
        title: title,
        completed_at: nil
      )
      guard reminder_past.due? == true
      
      # Test 2: Reminder with today's scheduled_date and nil completed_at should be due
      reminder_today = Reminder.create!(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: Date.today,
        title: title,
        completed_at: nil
      )
      guard reminder_today.due? == true
      
      # Test 3: Reminder with future scheduled_date should not be due
      future_date = Date.today + range(1, 30).days
      reminder_future = Reminder.create!(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: future_date,
        title: title,
        completed_at: nil
      )
      guard reminder_future.due? == false
      
      # Test 4: Reminder with past scheduled_date but completed_at set should not be due
      reminder_completed = Reminder.create!(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: past_date,
        title: title,
        completed_at: Time.current
      )
      guard reminder_completed.due? == false
      
      # Clean up
      reminder_past.destroy
      reminder_today.destroy
      reminder_future.destroy
      reminder_completed.destroy
    end
  end

  # Property 42: Reminder completion
  # Validates: Requirements 9.3
  # For any reminder, calling complete! should set completed_at to the current timestamp.
  test "property: reminder completion" do
    pet = pets(:one)
    
    Rantly(20) do
      # Create a reminder without completed_at
      reminder_type = choose("vet_appointment", "medication", "grooming", "custom")
      scheduled_date = Date.today + range(-30, 30).days
      title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup")
      
      reminder = Reminder.create!(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: scheduled_date,
        title: title,
        completed_at: nil
      )
      
      # Verify completed_at is initially nil
      guard reminder.completed_at.nil?
      
      # Record the time before calling complete!
      time_before = Time.current
      
      # Call complete!
      result = reminder.complete!
      
      # Verify the method returns truthy value (successful update)
      guard result
      
      # Reload the reminder from database
      reminder.reload
      
      # Verify completed_at is now set
      guard reminder.completed_at.present?
      
      # Verify completed_at is a timestamp (Time object)
      guard reminder.completed_at.is_a?(Time) || reminder.completed_at.is_a?(ActiveSupport::TimeWithZone)
      
      # Verify completed_at is recent (within last few seconds)
      time_after = Time.current
      guard reminder.completed_at >= time_before
      guard reminder.completed_at <= time_after
      
      # Clean up
      reminder.destroy
    end
  end

  # Property 43: Reminder type validation
  # Validates: Requirements 9.4
  # For any reminder creation attempt, the reminder should be rejected if
  # reminder_type is not one of [vet_appointment, medication, grooming, custom],
  # and accepted if it is.
  test "property: reminder type validation" do
    pet = pets(:one)
    
    Rantly(20) do
      scheduled_date = Date.today + range(-30, 180).days
      title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup")
      description = choose(nil, "Important reminder", "Don't forget")
      
      # Test 1: Reminder with INVALID reminder_type should be rejected
      invalid_type = choose("invalid", "appointment", "vet", "med", "groom", "other", "reminder", "")
      reminder_invalid = Reminder.new(
        pet: pet,
        reminder_type: invalid_type,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      guard !reminder_invalid.valid?
      guard reminder_invalid.errors[:reminder_type].present?
      
      # Test 2: Reminder with VALID reminder_type should be accepted
      valid_type = choose("vet_appointment", "medication", "grooming", "custom")
      reminder_valid = Reminder.new(
        pet: pet,
        reminder_type: valid_type,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      guard reminder_valid.valid?
      guard reminder_valid.save
      
      # Verify the reminder persists correctly
      retrieved = Reminder.find(reminder_valid.id)
      guard retrieved.reminder_type == valid_type
      
      # Clean up
      reminder_valid.destroy
    end
  end

  # Property 44: Reminder status grouping
  # Validates: Requirements 9.5
  # For any set of reminders for a pet, querying should allow filtering into
  # upcoming (future scheduled_date, not completed), due (past/today scheduled_date,
  # not completed), and completed (completed_at present) groups.
  test "property: reminder status grouping" do
    pet = pets(:one)
    
    Rantly(20) do
      # Create a mix of upcoming, due, and completed reminders
      num_reminders = range(5, 10)
      created_reminders = []
      
      num_reminders.times do
        reminder_type = choose("vet_appointment", "medication", "grooming", "custom")
        title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup")
        
        # Randomly decide the status of the reminder
        status_type = choose(:upcoming, :due, :completed)
        
        case status_type
        when :upcoming
          # Upcoming: future scheduled_date, not completed
          scheduled_date = Date.today + range(1, 180).days
          completed_at = nil
        when :due
          # Due: past or today scheduled_date, not completed
          scheduled_date = Date.today - range(0, 30).days
          completed_at = nil
        when :completed
          # Completed: any scheduled_date, completed_at present
          scheduled_date = Date.today + range(-30, 180).days
          completed_at = Time.current - range(0, 86400).seconds
        end
        
        reminder = Reminder.create!(
          pet: pet,
          reminder_type: reminder_type,
          scheduled_date: scheduled_date,
          title: title,
          completed_at: completed_at
        )
        
        created_reminders << { reminder: reminder, status: status_type }
      end
      
      # Query upcoming reminders
      upcoming_reminders = pet.reminders.upcoming.to_a
      
      # Verify all upcoming reminders have future scheduled_date and nil completed_at
      upcoming_reminders.each do |reminder|
        guard reminder.scheduled_date > Date.today
        guard reminder.completed_at.nil?
      end
      
      # Query due reminders
      due_reminders = pet.reminders.due.to_a
      
      # Verify all due reminders have past/today scheduled_date and nil completed_at
      due_reminders.each do |reminder|
        guard reminder.scheduled_date <= Date.today
        guard reminder.completed_at.nil?
      end
      
      # Query completed reminders
      completed_reminders = pet.reminders.completed.to_a
      
      # Verify all completed reminders have completed_at present
      completed_reminders.each do |reminder|
        guard reminder.completed_at.present?
      end
      
      # Verify that the three groups don't overlap
      upcoming_ids = upcoming_reminders.map(&:id)
      due_ids = due_reminders.map(&:id)
      completed_ids = completed_reminders.map(&:id)
      
      guard (upcoming_ids & due_ids).empty?
      guard (upcoming_ids & completed_ids).empty?
      guard (due_ids & completed_ids).empty?
      
      # Verify that all created reminders are in one of the three groups
      created_reminders.each do |item|
        reminder_id = item[:reminder].id
        case item[:status]
        when :upcoming
          guard upcoming_ids.include?(reminder_id)
        when :due
          guard due_ids.include?(reminder_id)
        when :completed
          guard completed_ids.include?(reminder_id)
        end
      end
      
      # Clean up
      created_reminders.each { |item| item[:reminder].destroy }
    end
  end

  # Property 45: Reminder-pet association
  # Validates: Requirements 9.6
  # For any reminder creation attempt, the reminder should be rejected without
  # a pet association and accepted with a valid pet association.
  test "property: reminder-pet association" do
    pet = pets(:one)
    
    Rantly(20) do
      # Generate random valid attributes for a reminder
      reminder_type = choose("vet_appointment", "medication", "grooming", "custom")
      scheduled_date = Date.today + range(-30, 180).days
      title = choose("Vet Visit", "Medication Time", "Grooming", "Checkup", "Vaccination")
      description = choose(nil, "Important reminder", "Don't forget", "Regular care")
      
      # Test 1: Reminder WITHOUT pet association should be rejected
      reminder_without_pet = Reminder.new(
        reminder_type: reminder_type,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      
      # The reminder should be invalid without a pet
      guard !reminder_without_pet.valid?
      guard reminder_without_pet.errors[:pet].present?
      
      # Attempting to save should fail
      guard !reminder_without_pet.save
      
      # Test 2: Reminder WITH valid pet association should be accepted
      reminder_with_pet = Reminder.new(
        pet: pet,
        reminder_type: reminder_type,
        scheduled_date: scheduled_date,
        title: title,
        description: description
      )
      
      # The reminder should be valid with a pet
      guard reminder_with_pet.valid?
      
      # Saving should succeed
      guard reminder_with_pet.save
      
      # Retrieve the reminder and verify the pet association is preserved
      retrieved = Reminder.find(reminder_with_pet.id)
      guard retrieved.pet_id == pet.id
      guard retrieved.pet == pet
      
      # Clean up
      reminder_with_pet.destroy
    end
  end
end
