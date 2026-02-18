require "test_helper"

class ReminderServiceTest < ActiveSupport::TestCase
  # Property 46: Alert context transfer
  # Validates: Requirements 10.2
  # For any health alert that creates a reminder, the reminder should contain
  # the alert context in its description or alert_context field.
  test "property: alert context transfer to reminders" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: PropertyGenerators.random_pet_name,
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Generate random alert context with various alert types and messages
      alert_types = ['low_weight', 'low_activity', 'declining_trend', 'custom_alert']
      alert_type = choose(*alert_types)
      
      # Generate a meaningful message based on alert type
      messages = {
        'low_weight' => "Weight below recommended threshold for #{pet.species}",
        'low_activity' => "Activity level is concerning",
        'declining_trend' => "Weight has been declining over recent records",
        'custom_alert' => "Custom health concern detected"
      }
      
      alert_message = messages[alert_type]
      
      # Generate random severity
      severity = choose('low', 'medium', 'high', 'critical')
      
      # Create alert context hash
      alert_context = {
        type: alert_type,
        message: alert_message,
        severity: severity
      }
      
      # Create reminder from health alert
      reminder = ReminderService.create_from_health_alert(pet, alert_context)
      
      # Verify reminder was created successfully
      guard reminder.persisted?
      
      # Verify reminder has correct pet association
      guard reminder.pet_id == pet.id
      
      # Verify reminder type is vet_appointment
      guard reminder.reminder_type == 'vet_appointment'
      
      # Verify scheduled_date is 7 days from now
      guard reminder.scheduled_date == 7.days.from_now.to_date
      
      # Verify title is set correctly
      guard reminder.title == 'Vet Appointment Recommended'
      
      # Verify alert context is transferred to description
      guard reminder.description.present?
      guard reminder.description.include?(alert_message)
      guard reminder.description.include?("Health alert:")
      
      # Verify alert_context field contains the full context as JSON
      guard reminder.alert_context.present?
      
      # Parse the JSON and verify it matches the original alert context
      parsed_context = JSON.parse(reminder.alert_context, symbolize_names: true)
      guard parsed_context[:type] == alert_type
      guard parsed_context[:message] == alert_message
      guard parsed_context[:severity] == severity
      
      # Clean up
      reminder.destroy
      pet.destroy
    end
  end
  
  # Additional test: mark_due_reminders updates status correctly
  test "property: mark_due_reminders updates status for due reminders" do
    user = users(:one)
    
    Rantly(20) do
      # Create a pet
      pet = Pet.create!(
        name: PropertyGenerators.random_pet_name,
        species: PropertyGenerators.random_species,
        user: user
      )
      
      # Create reminders with various scheduled dates
      # Some in the past (should be marked due)
      # Some today (should be marked due)
      # Some in the future (should not be marked due)
      
      past_days = range(1, 30)
      past_reminder = Reminder.create!(
        pet: pet,
        reminder_type: PropertyGenerators.random_reminder_type,
        scheduled_date: Date.today - past_days.days,
        title: "Past Reminder",
        status: 'pending'
      )
      
      today_reminder = Reminder.create!(
        pet: pet,
        reminder_type: PropertyGenerators.random_reminder_type,
        scheduled_date: Date.today,
        title: "Today Reminder",
        status: 'pending'
      )
      
      future_days = range(1, 30)
      future_reminder = Reminder.create!(
        pet: pet,
        reminder_type: PropertyGenerators.random_reminder_type,
        scheduled_date: Date.today + future_days.days,
        title: "Future Reminder",
        status: 'pending'
      )
      
      # Mark due reminders
      ReminderService.mark_due_reminders
      
      # Reload reminders to get updated status
      past_reminder.reload
      today_reminder.reload
      future_reminder.reload
      
      # Verify past and today reminders are marked as due
      guard past_reminder.status == 'due'
      guard today_reminder.status == 'due'
      
      # Verify future reminder is still pending
      guard future_reminder.status == 'pending'
      
      # Clean up
      past_reminder.destroy
      today_reminder.destroy
      future_reminder.destroy
      pet.destroy
    end
  end
end
