class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :vet_office, null: false, foreign_key: true, index: true
      t.string :contact_type, null: false
      t.string :contact_value, null: false
      t.boolean :is_primary, default: false

      t.timestamps
    end
    
    add_index :contacts, [:vet_office_id, :contact_type, :is_primary]
  end
end
