class Api::V1::TablesController < ApplicationController
  def index
    if params[:date]&.present? && params[:time]&.present?
      date = DateTime.parse(params[:date])
      results = calender_api(date, params[:time])
      get_available_tables(results)
    end
    @tables ||= Table.all
    render json: { tables: @tables }
  end

  private

  def add_bookings

  end

  def calendar_api(date, time)
    @calendar = Calendar::Calendar.new
    @calendar.find_events_on_day(date, time)
  end

  def get_available_tables(results)
    if results.items.empty?
      @tables = Table.all
    elsif results.items.size >= 3
      @tables = []
    else
      tables_in_use = results.items.collect(&:location)
      # tell me ruby isn't pretty
      @tables = Table.where.not(name: tables_in_use)
    end
  end
end
