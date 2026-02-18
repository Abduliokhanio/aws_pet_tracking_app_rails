class CreateDismissedAlerts < ActiveRecord::Migration[8.1]
  def change
    create_table :dismissed_alerts do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :alert_type, null: false
      t.string :alert_condition, null: false
      t.datetime :dismissed_at, null: false

      t.timestamps
    end

    add_index :dismissed_alerts, [:pet_id, :alert_type, :alert_condition], name: 'index_dismissed_alerts_on_pet_type_condition'
  end
end
