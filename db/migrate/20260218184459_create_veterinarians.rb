class CreateVeterinarians < ActiveRecord::Migration[8.1]
  def change
    create_table :veterinarians do |t|
      t.references :vet_office, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.text :work_history
      t.integer :years_of_experience

      t.timestamps
    end
  end
end
