class VeterinariansController < ApplicationController
  before_action :set_veterinarian, only: %i[show edit update destroy]

  # GET /veterinarians
  def index
    @veterinarians = Veterinarian.includes(:vet_office, :ratings).all
  end

  # GET /veterinarians/1
  def show
    @ratings = @veterinarian.ratings.includes(:user).order(created_at: :desc)
  end

  # GET /veterinarians/new
  def new
    @veterinarian = Veterinarian.new
  end

  # GET /veterinarians/1/edit
  def edit
  end

  # POST /veterinarians
  def create
    @veterinarian = Veterinarian.new(veterinarian_params)

    respond_to do |format|
      if @veterinarian.save
        format.html { redirect_to veterinarian_path(@veterinarian), notice: "Veterinarian was successfully created." }
        format.json { render :show, status: :created, location: @veterinarian }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @veterinarian.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /veterinarians/1
  def update
    respond_to do |format|
      if @veterinarian.update(veterinarian_params)
        format.html { redirect_to veterinarian_path(@veterinarian), notice: "Veterinarian was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @veterinarian }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @veterinarian.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /veterinarians/1
  def destroy
    @veterinarian.destroy!

    respond_to do |format|
      format.html { redirect_to veterinarians_path, notice: "Veterinarian was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_veterinarian
    @veterinarian = Veterinarian.find(params.expect(:id))
  end

  def veterinarian_params
    params.expect(veterinarian: [:name, :work_history, :years_of_experience, :vet_office_id])
  end
end
