class Api::V1::TablesController < ApplicationController
  def index
        # binding.pry
    if params[:date]&.present? && params[:time]&.present?
      date = format_date(params[:date])
      results = calendar_api(date, params[:time])
      # binding.pry
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
      @tables = Table.all.each(&:active)
    else
      tables_in_use = results.items.collect(&:location)
      @tables = Table.all.each {|table| table.active = true if tables_in_use.include?(table.name)}
    end
  end
end
