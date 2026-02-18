class CreatePetHealthThresholds < ActiveRecord::Migration[8.1]
  def change
    create_table :pet_health_thresholds do |t|
      t.references :pet, null: false, foreign_key: true
      t.string :threshold_type, null: false
      t.decimal :threshold_value, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :pet_health_thresholds, [:pet_id, :threshold_type], unique: true
  end
end
