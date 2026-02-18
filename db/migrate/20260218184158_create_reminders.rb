class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :reminder_type, null: false
      t.date :scheduled_date, null: false
      t.string :title, null: false
      t.text :description
      t.datetime :completed_at
      t.string :status, default: 'pending'
      t.text :alert_context

      t.timestamps
    end

    add_index :reminders, [:pet_id, :scheduled_date]
    add_index :reminders, :status
  end
end
