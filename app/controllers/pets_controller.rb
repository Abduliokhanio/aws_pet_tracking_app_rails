class PetsController < ApplicationController
  before_action :set_pet, only: %i[ show edit update destroy dashboard ]
  before_action :set_user

  # GET /pets or /pets.json
  def index
    @pets = Pet.all
  end

  # GET /pets/1 or /pets/1.json
  def show
    @pets = @user.pets
  end

  # GET /pets/1/dashboard
  def dashboard
    @recent_health_records = @pet.health_records.chronological.limit(5)
    @upcoming_reminders = @pet.reminders.upcoming.limit(5)
    @active_medications = @pet.medications.active
    @visualization_data = VisualizationService.new(@pet, start_date: 30.days.ago).weight_chart_data
  end

  # GET /pets/new
  def new
    @pet = Pet.new
  end

  # GET /pets/1/edit
  def edit
  end

  # POST /pets or /pets.json
  def create
    @pet = Pet.new(pet_params)

    respond_to do |format|
      if @pet.save
        format.html { redirect_to user_pet_path(@user, @pet), notice: "Pet was successfully created." }
        format.json { render :show, status: :created, location: user_pet_url(@user, @pet) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pets/1 or /pets/1.json
  def update
    respond_to do |format|
      if @pet.update(pet_params)
        format.html { redirect_to user_pet_path(@user, @pet), notice: "Pet was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: user_pet_url(@user, @pet) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @pet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/1 or /pets/1.json
  def destroy
    @pet.destroy!

    respond_to do |format|
      format.html { redirect_to user_pets_path, notice: "Pet was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pet
      @pet = Pet.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def pet_params
      params.expect(pet: [ :name, :gender, :species, :user_id ])
    end

    def set_user
      @user = User.find(params[:user_id])
    end
end


