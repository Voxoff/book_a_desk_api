class Api::V1::TablesController < ApplicationController
  def index
    @tables = Table.all
    render json: { tables: @tables }
  end

end
