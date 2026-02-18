class ChangeDoseToDecimalInMedications < ActiveRecord::Migration[8.1]
  def change
    change_column :medications, :dose, :decimal, precision: 10, scale: 2, null: false
  end
end
