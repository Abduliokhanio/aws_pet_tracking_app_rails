class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :veterinarian, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating_value, null: false
      t.text :review_text

      t.timestamps
    end
    
    add_index :ratings, [:user_id, :veterinarian_id], unique: true
  end
end
