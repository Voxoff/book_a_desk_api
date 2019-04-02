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

    OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
    APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
    CREDENTIALS_PATH = 'credentials.json'.freeze
    # The file token.yaml stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    TOKEN_PATH = 'token.yaml'.freeze
    SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    return service
  end

  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
          "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def new_event(table)
    require 'date'
    require 'active_support/time'

    puts table.name
    event = Google::Apis::CalendarV3::Event.new({
      location: 'Ive',
      start: {
        date_time: DateTime.now.to_s,
      },
      end: {
        date_time: DateTime.now.advance(hours: 2).to_s
      },
      attendees: [{email: 'lpage@example.com'}]
    })
    event
  end

  def add_event
    new_event
    result = service.insert_event('primary', event)
  end

  def list_events
    calendar_id = 'primary'
    response = service.list_events(calendar_id,
                                  max_results: 10,
                                  single_events: true,
                                  order_by: 'startTime',
                                  time_min: DateTime.now.rfc3339)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    response.items.each do |event|
      start = event.start.date || event.start.date_time
    puts "- #{event.summary} (#{start})"
  end

  end
end
