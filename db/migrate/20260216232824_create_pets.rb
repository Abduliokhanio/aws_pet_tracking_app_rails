class CreatePets < ActiveRecord::Migration[8.1]
  def change
    create_table :pets do |t|
      t.string :name
      t.string :gender
      t.string :species
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
