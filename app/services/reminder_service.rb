class ReminderService
  def self.create_from_health_alert(pet, alert_context)
    Reminder.create(
      pet: pet,
      reminder_type: 'vet_appointment',
      scheduled_date: 7.days.from_now,
      title: 'Vet Appointment Recommended',
      description: "Health alert: #{alert_context[:message]}",
      alert_context: alert_context.to_json
    )
  end
  
  def self.mark_due_reminders
    Reminder.where('scheduled_date <= ? AND completed_at IS NULL', Date.today)
            .update_all(status: 'due')
  end
end
