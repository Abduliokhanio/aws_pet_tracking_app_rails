class CreateMedicationDosages < ActiveRecord::Migration[8.1]
  def change
    create_table :medication_dosages do |t|
      t.references :medication, null: false, foreign_key: true
      t.decimal :dose, precision: 10, scale: 2, null: false
      t.date :recorded_on, null: false
      t.text :notes

      t.timestamps
    end
    
    add_index :medication_dosages, [:medication_id, :recorded_on]
  end
end
