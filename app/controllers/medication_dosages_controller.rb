class MedicationDosagesController < ApplicationController
  before_action :set_pet_and_medication
  before_action :set_medication_dosage, only: [:edit, :update, :destroy]

  def new
    @medication_dosage = @medication.medication_dosages.build(recorded_on: Date.today)
  end

  def create
    @medication_dosage = @medication.medication_dosages.build(medication_dosage_params)

    if @medication_dosage.save
      # Update medication's current dose to the latest
      latest_dosage = @medication.medication_dosages.order(recorded_on: :desc).first
      @medication.update(dose: latest_dosage.dose)
      redirect_to pet_medication_path(@pet, @medication), notice: "Dosage change recorded successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @medication_dosage.update(medication_dosage_params)
      # Update medication's current dose to the latest
      latest_dosage = @medication.medication_dosages.order(recorded_on: :desc).first
      @medication.update(dose: latest_dosage.dose)
      redirect_to pet_medication_path(@pet, @medication), notice: "Dosage record updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @medication_dosage.destroy!
    # Update medication's current dose to the latest remaining dosage
    latest_dosage = @medication.medication_dosages.order(recorded_on: :desc).first
    @medication.update(dose: latest_dosage&.dose || 0) if latest_dosage
    redirect_to pet_medication_path(@pet, @medication), notice: "Dosage record deleted.", status: :see_other
  end

  private

  def set_pet_and_medication
    @pet = Pet.find(params[:pet_id])
    @medication = @pet.medications.find(params[:medication_id])
  end

  def set_medication_dosage
    @medication_dosage = @medication.medication_dosages.find(params[:id])
  end

  def medication_dosage_params
    params.require(:medication_dosage).permit(:dose, :recorded_on, :notes)
  end
end
