class Api::V1::SessionsController < ApplicationController
  # skip_before_action :verify_authenticity_token
  def new
    binding.pry
  end

  def create
    binding.pry
    user = User.from_omniauth(env["omniauth.auth"])

    if user.valid?
      session[:user_id] = user.id
      redirect_to request.env['omniauth.origin']
    end
  end

  def destroy
    reset_session
    redirect_to request.referer
  end
end
