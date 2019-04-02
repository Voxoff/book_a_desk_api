require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'

@@oob_uri = 'urn:ietf:wg:oauth:2.0:oob'.freeze
@@application_name = 'Google Calendar API Ruby Quickstart'.freeze
@@credentials_path = 'credentials.json'.freeze
# The file token.yaml stores the user's access and refresh tokens, and is
# created automatically when the authorization flow completes for the first
# time.
@@token_path = 'token.yaml'.freeze
@@scope = Google::Apis::CalendarV3::AUTH_CALENDAR

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(@@credentials_path)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: @@token_path)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, @@scope, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: @@oob_uri)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: @@oob_uri
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = @@application_name
service.authorization = authorize

# Fetch the next 10 events for the user
# calendar_id = 'primary'
# response = service.list_events(calendar_id,
#                                max_results: 10,
#                                single_events: true,
#                                order_by: 'startTime',
#                                time_min: DateTime.now.rfc3339)
# puts 'Upcoming events:'
# puts 'No upcoming events found' if response.items.empty?
# response.items.each do |event|
#   start = event.start.date || event.start.date_time
#   puts "- #{event.summary} (#{start})"
# end

require 'date'
require 'active_support/time'

event = Google::Apis::CalendarV3::Event.new({
  location: 'Ive',
  start: {
    date_time: DateTime.now.to_s,
  },
  end: {
    date_time: DateTime.now.advance(hours: 2).to_s,
    time_zone: 'America/Los_Angeles',
  },
  attendees: [{email: 'lpage@example.com'}]
})

result = service.insert_event('primary', event)
