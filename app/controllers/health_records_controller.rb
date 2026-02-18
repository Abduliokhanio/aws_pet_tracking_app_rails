class HealthRecordsController < ApplicationController
  before_action :set_pet
  before_action :set_health_record, only: %i[show edit update destroy]

  # GET /pets/:pet_id/health_records
  def index
    @health_records = @pet.health_records.chronological.page(params[:page])
    visualization_service = VisualizationService.new(@pet)
    @visualization_data = visualization_service.weight_chart_data
    @health_metrics_data = visualization_service.health_metrics_data
  end

  # GET /pets/:pet_id/health_records/1
  def show
  end

  # GET /pets/:pet_id/health_records/new
  def new
    @health_record = @pet.health_records.build
  end

  # GET /pets/:pet_id/health_records/1/edit
  def edit
  end

  # POST /pets/:pet_id/health_records
  def create
    @health_record = @pet.health_records.build(health_record_params)

    respond_to do |format|
      if @health_record.save
        HealthAlertService.new(@health_record).check_and_alert
        format.html { redirect_to pet_health_records_path(@pet), notice: "Health record was successfully created." }
        format.json { render :show, status: :created, location: pet_health_record_url(@pet, @health_record) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @health_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pets/:pet_id/health_records/1
  def update
    respond_to do |format|
      if @health_record.update(health_record_params)
        format.html { redirect_to pet_health_record_path(@pet, @health_record), notice: "Health record was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: pet_health_record_url(@pet, @health_record) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @health_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/:pet_id/health_records/1
  def destroy
    @health_record.destroy!

    respond_to do |format|
      format.html { redirect_to pet_health_records_path(@pet), notice: "Health record was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # GET /pets/:pet_id/health_records/export
  def export
    start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 6.months.ago
    end_date = params[:end_date].present? ? Date.parse(params[:end_date]) : Date.today
    
    @health_records = @pet.health_records
                          .where(recorded_on: start_date..end_date)
                          .chronological

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"#{@pet.name}_health_records_#{Date.today}.csv\""
        headers['Content-Type'] = 'text/csv'
      end
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
  end

  def set_health_record
    @health_record = @pet.health_records.find(params.expect(:id))
  end

  def health_record_params
    params.expect(health_record: [
      :weight, :recorded_on, :mood, :activity_level, :food_intake,
      :medication_name, :medication_dose, :status, :notes, :medication_id
    ])
  end
end
