class ChangeDoseToDecimalInMedications < ActiveRecord::Migration[8.1]
  def up
    change_column :medications,
                  :dose,
                  :decimal,
                  precision: 10,
                  scale: 2,
                  null: false,
                  using: "dose::numeric"
  end

  def down
    change_column :medications, :dose, :string
  end
end