class RatingsController < ApplicationController
  before_action :set_veterinarian
  before_action :set_current_user

  # POST /veterinarians/:veterinarian_id/ratings
  def create
    @rating = @veterinarian.ratings.build(rating_params)
    @rating.user = @current_user

    respond_to do |format|
      if @rating.save
        format.html { redirect_to veterinarian_path(@veterinarian), notice: "Rating was successfully created." }
        format.json { render json: @rating, status: :created }
      else
        format.html { redirect_to veterinarian_path(@veterinarian), alert: @rating.errors.full_messages.join(", ") }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /veterinarians/:veterinarian_id/ratings/:id
  def update
    @rating = @veterinarian.ratings.find_by(user: @current_user)

    respond_to do |format|
      if @rating && @rating.update(rating_params)
        format.html { redirect_to veterinarian_path(@veterinarian), notice: "Rating was successfully updated.", status: :see_other }
        format.json { render json: @rating, status: :ok }
      else
        format.html { redirect_to veterinarian_path(@veterinarian), alert: "Unable to update rating." }
        format.json { render json: { error: "Rating not found or update failed" }, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_veterinarian
    @veterinarian = Veterinarian.find(params[:veterinarian_id])
  end

  def set_current_user
    # TODO: Replace with actual current_user from authentication system
    # For now, using the first user or params
    @current_user = User.first || User.find(params[:user_id])
  end

  def rating_params
    params.expect(rating: [:rating_value, :review_text])
  end
end
