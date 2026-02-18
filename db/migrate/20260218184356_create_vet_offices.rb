class CreateVetOffices < ActiveRecord::Migration[8.1]
  def change
    create_table :vet_offices do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
