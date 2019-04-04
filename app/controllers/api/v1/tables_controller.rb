class Api::V1::TablesController < ApplicationController
  def index
    if params[:date]&.present? && params[:time]&.present?
      date = format_date(params[:date])
      results = calendar_api(date, params[:time])
      @tables = get_available_tables(results)
    end
    @tables ||= Table.all
    render json: { tables: @tables }
  end

  def add_booking
    if params[:date]&.present? && params[:time]&.present? && params[:name]&.present?
      @calendar = Calendar::Calendar.new
      @table_name = Table.where(name: params[:name]).pluck(:name).first
      date = format_date(params[:date])
      @calendar.add_event(@table_name, date, params[:time])
    end
    render json: { message: "added"}
  end

  private

  def format_date(date)
    puts params[:date]
    DateTime.parse(date)
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
