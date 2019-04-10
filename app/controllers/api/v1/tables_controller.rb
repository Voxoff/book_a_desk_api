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
    # need a check for already ordered.
    if booking_params.none? { |_,v| v.nil? || v.empty? }
      @calendar = Calendar::Calendar.new
      # @table_name = Table.where(name: params[:name]).pluck(:name).first
      @calendar.add_event(
                          Table.find_by_name(params[:name]).first,
                          format_date(params[:date]),
                          params[:time],
                          current_user
                         )
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
      @tables = Table.all.each { |table| table.active = true if tables_in_use.include?(table.name)}
    end
  end

  def booking_params
    params.permit(:date, :time, :name)
  end
  #this any good???
  def none_proc
    Proc.new  { |x| x.none? { |k,v| v.nil? || v.empty? } }
  end
end
