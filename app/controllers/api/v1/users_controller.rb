class Api::V1::UsersController < ApplicationController
  skip_before_action :authorized, only: [:create, :omniauth]

  def profile
    render json: { user: UserSerializer.new(current_user) }, status: :accepted
  end

  def create
    @user = User.create(user_params)
    if @user.valid?
      @token = encode_token({ user_id: @user.id })
      render json: { user: UserSerializer.new(@user), jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  def omniauth
    @user = User.from_omniauth(github_params)
    if @user.valid?
      @token = encode_token({ user_id: @user.id })
      render json: { user: @user, jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private

  def github_params
    p = params.require(:_profile).permit(:id, :name, :firstName, :lastName, :email, :profilePicURL)
    p.merge(params.require(:_token).permit(:accessToken)).merge(params.permit(:_provider))
  end

  def user_params
    params.require(:user).permit(:username, :password, :bio, :avatar)
  end
end
