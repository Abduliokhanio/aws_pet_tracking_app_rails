class CreateMedications < ActiveRecord::Migration[8.1]
  def change
    create_table :medications do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :medication_name, null: false
      t.string :dose, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.text :notes

      t.timestamps
    end

    add_index :medications, [:pet_id, :start_date]
  end
end
