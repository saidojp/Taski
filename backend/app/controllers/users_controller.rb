class UsersController < ApplicationController
  skip_before_action :authorize_request, only: :create

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      render json: { token: token, user: @user }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /users (all users for invite)
  def index
    render json: User.select(:id, :name, :email)
  end

  # GET /users/me
  def me
    render json: @current_user
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
