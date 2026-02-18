class RemindersController < ApplicationController
  before_action :set_pet
  before_action :set_reminder, only: %i[show edit update destroy complete]

  # GET /pets/:pet_id/reminders
  def index
    @upcoming_reminders = @pet.reminders.upcoming
    @due_reminders = @pet.reminders.due
    @completed_reminders = @pet.reminders.completed
  end

  # GET /pets/:pet_id/reminders/1
  def show
  end

  # GET /pets/:pet_id/reminders/new
  def new
    @reminder = @pet.reminders.build
  end

  # GET /pets/:pet_id/reminders/1/edit
  def edit
  end

  # POST /pets/:pet_id/reminders
  def create
    @reminder = @pet.reminders.build(reminder_params)

    respond_to do |format|
      if @reminder.save
        format.html { redirect_to pet_reminders_path(@pet), notice: "Reminder was successfully created." }
        format.json { render :show, status: :created, location: pet_reminder_url(@pet, @reminder) }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /pets/:pet_id/reminders/1
  def update
    respond_to do |format|
      if @reminder.update(reminder_params)
        format.html { redirect_to pet_reminder_path(@pet, @reminder), notice: "Reminder was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: pet_reminder_url(@pet, @reminder) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /pets/:pet_id/reminders/1
  def destroy
    @reminder.destroy!

    respond_to do |format|
      format.html { redirect_to pet_reminders_path(@pet), notice: "Reminder was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # POST /pets/:pet_id/reminders/1/complete
  def complete
    @reminder.complete!

    respond_to do |format|
      format.html { redirect_to pet_reminders_path(@pet), notice: "Reminder was marked as complete.", status: :see_other }
      format.json { render :show, status: :ok, location: pet_reminder_url(@pet, @reminder) }
    end
  end

  private

  def set_pet
    @pet = Pet.find(params[:pet_id])
  end

  def set_reminder
    @reminder = @pet.reminders.find(params.expect(:id))
  end

  def reminder_params
    params.expect(reminder: [:reminder_type, :scheduled_date, :title, :description])
  end
end
