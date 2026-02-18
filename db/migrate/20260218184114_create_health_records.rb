class CreateHealthRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :health_records do |t|
      t.references :pet, null: false, foreign_key: true
      t.references :medication, foreign_key: true
      t.decimal :weight, precision: 5, scale: 2
      t.date :recorded_on, null: false
      t.string :mood
      t.string :activity_level
      t.string :food_intake
      t.string :medication_name
      t.string :medication_dose
      t.string :status
      t.text :notes

      t.timestamps
    end

    add_index :health_records, :recorded_on
    add_index :health_records, [:pet_id, :recorded_on]
  end
end
