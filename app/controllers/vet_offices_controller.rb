class VetOfficesController < ApplicationController
  before_action :set_vet_office, only: %i[show edit update destroy]

  # GET /vet_offices
  def index
    @vet_offices = VetOffice.includes(:address, :contacts, :veterinarians).all
  end

  # GET /vet_offices/1
  def show
  end

  # GET /vet_offices/new
  def new
    @vet_office = VetOffice.new
    @vet_office.build_address
    @vet_office.contacts.build
  end

  # GET /vet_offices/1/edit
  def edit
  end

  # POST /vet_offices
  def create
    @vet_office = VetOffice.new(vet_office_params)

    respond_to do |format|
      if @vet_office.save
        format.html { redirect_to vet_office_path(@vet_office), notice: "Vet office was successfully created." }
        format.json { render :show, status: :created, location: @vet_office }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @vet_office.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vet_offices/1
  def update
    respond_to do |format|
      if @vet_office.update(vet_office_params)
        format.html { redirect_to vet_office_path(@vet_office), notice: "Vet office was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @vet_office }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @vet_office.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vet_offices/1
  def destroy
    @vet_office.destroy!

    respond_to do |format|
      format.html { redirect_to vet_offices_path, notice: "Vet office was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private

  def set_vet_office
    @vet_office = VetOffice.find(params.expect(:id))
  end

  def vet_office_params
    params.expect(vet_office: [
      :name,
      address_attributes: [:id, :city, :state, :zipcode, :country],
      contacts_attributes: [:id, :contact_type, :contact_value, :is_primary, :_destroy]
    ])
  end
end
