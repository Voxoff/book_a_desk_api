module Calendar
  class Calendar
    def initialize
      @service = set_up
    end

    def set_up
      require 'google/apis/calendar_v3'
      require 'googleauth'
      require 'googleauth/stores/file_token_store'
      require 'date'
      require 'fileutils'
      require 'json'

      @oob_uri = 'urn:ietf:wg:oauth:2.0:oob'.freeze
      @application_name = 'Google Calendar API Ruby Quickstart'.freeze
      # @credentials_path = 'credentials.json'.freeze
      @credentials_path = ENV['GOOGLE_APPLICATION_CREDENTIALS']
      # The file token.yaml stores the user's access and refresh tokens, and is
      # created automatically when the authorization flow completes for the first
      # time.
      @token_path = 'token.yaml'.freeze
      @scope = Google::Apis::CalendarV3::AUTH_CALENDAR

      service = Google::Apis::CalendarV3::CalendarService.new
      service.client_options.application_name = @application_name
      service.authorization = authorize
      return service
    end

    def authorize
      client_id = Google::Auth::ClientId.from_hash(JSON.parse(@credentials_path))
      token_store = Google::Auth::Stores::FileTokenStore.new(file: @token_path)
      authorizer = Google::Auth::UserAuthorizer.new(client_id, @scope, token_store)
      user_id = 'default'
      credentials = authorizer.get_credentials(user_id)
      if credentials.nil?
        url = authorizer.get_authorization_url(base_url: @oob_uri)
        puts 'Open the following URL in the browser and enter the ' \
            "resulting code after authorization:\n" + url
        code = gets
        credentials = authorizer.get_and_store_credentials_from_code(
          user_id: user_id, code: code, base_url: @oob_uri
        )
      end
      credentials
    end

    def new_event(table_name, date, time_bool, user)
      require 'date'
      require 'active_support/time'

      time_min, time_max = calc_time(date, time_bool)
      Google::Apis::CalendarV3::Event.new({
        location: table_name,
        start: { date_time: time_min.to_s },
        end: { date_time: time_max.to_s },
        text: "##{user.username} (#{user.email}) has booked #{table_name}",
        attendees: [{email: user.email.to_s}],
        summary: "##{user.username} (#{user.email}) has booked #{table_name}"
      })
    end

    def add_event(attr = {})
      event = new_event(attr[:table_name],attr[:date], attr[:time], attr[:user])
      @service.insert_event('primary', event)
    end

    def find_events_on_day(date, time_bool)
      time_min, time_max = calc_time(date, time_bool)
      # binding.pry
      @service.list_events('primary',
                          time_min: time_min.to_s,
                          time_max: time_max.to_s)
    end

    def calc_time(date, time_bool)
      if time_bool == "morning"
        time_min = date.advance(hours: 9)
        time_max = date.advance(hours: 12)
      else
        time_min = date.advance(hours: 13)
        time_max = date.advance(hours: 21)
      end
      return [time_min, time_max]
    end

    def list_events(date)
      @service.list_events('primary',
                           max_results: 10,
                           single_events: true,
                           order_by: 'startTime',
                           time_min: DateTime.parse(date))
    end
  end
end
