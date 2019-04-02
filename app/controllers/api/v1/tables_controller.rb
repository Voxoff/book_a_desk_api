class Api::V1::TablesController < ApplicationController
  def index
    binding.pry
    if params[:date].empty? || params[:time].empty?
      @tables = Table.all
    else
      #go to api
      @calendar = Calendar::Calendar.new
      binding.pry
      @tables = Table.all
    end
    render json: { tables: @tables }
  end

end
