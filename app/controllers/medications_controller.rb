class MedicationsController < ApplicationController
  before_action :set_pet
  before_action :set_medication, only: %i[show edit update destroy]

  # GET /pets/:pet_id/medications
  def index
    @medications = @pet.medications.order(start_date: :desc)
    @active_medications = @pet.medications.active
    @inactive_medications = @pet.medications.inactive
    @timeline_data = VisualizationService.new(@pet).medication_timeline_data
  end

  # GET /pets/:pet_id/medications/1
  def show
  end

  # GET /pets/:pet_id/medications/new
  def new
    @medication = @pet.medications.build
  end

  # GET /pets/:pet_id/medications/1/edit
  def edit
  end

  # POST /pets/:pet_id/medications
  def create
    @medication = @pet.medications.build(medication_params)

    respond_to do |format|
      if @medication.save
        format.html { redirect_to pet_medications_path(@pet), notice: "Medication was successfully created." }
        format.json { render :show, status: :created, location: pet_medication_url(@pet, @medication) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pets/:pet_id/medications/1
  def update
    respond_to do |format|
      if @medication.update(medication_params)
        format.html { redirect_to pet_medication_path(@pet, @medication), notice: "Medication was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: pet_medication_url(@pet, @medication) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @medication.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/:pet_id/medications/1
  def destroy
    @medication.destroy!

    respond_to do |format|
      format.html { redirect_to pet_medications_path(@pet), notice: "Medication was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /pets/:pet_id/medications/export
  def export
    @medications = @pet.medications.order(start_date: :desc)

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"#{@pet.name}_medications_#{Date.today}.csv\""
        headers['Content-Type'] = 'text/csv'
      end
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
    @user = @pet.user
  end

  def set_medication
    @medication = @pet.medications.find(params.expect(:id))
  end

  def medication_params
    params.expect(medication: [:medication_name, :dose, :start_date, :end_date, :notes])
  end
end
