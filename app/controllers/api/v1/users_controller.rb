class Api::V1::UsersController < ApplicationController
  skip_before_action :authorized, only: [:create, :omni, :try]

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

  def try
    payload = {code: params["code"], client_id: ENV['CLIENT_ID'], client_secret: ENV['CLIENT_SECRET']}
    resp = RestClient.post("https://github.com/login/oauth/access_token", payload)
  end

  def omni
    @user = User.from_omniauth(auth_hash)
    if @user.valid?
      @token = encode_token({ user_id: @user.id })
      render json: { user: @user, jwt: @token }, status: :created
    else
      render json: { error: 'failed to create user' }, status: :not_acceptable
    end
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def user_params
    params.require(:user).permit(:username, :password, :bio, :avatar)
  end
end
