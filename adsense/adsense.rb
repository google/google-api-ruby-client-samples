# AdSense Management API command-line sample.
require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'

API_VERSION = 'v1.3'
CACHED_API_FILE = "adsense-#{API_VERSION}.cache"
CREDENTIAL_STORE_FILE = "#{$0}-oauth2.json"

# Handles authentication and loading of the API.
def setup()
  log_file = File.open('adsense.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG

  client = Google::APIClient.new(:application_name => 'Ruby AdSense sample',
                                 :application_version => '1.0.0')

  # FileStorage stores auth credentials in a file, so they survive multiple runs
  # of the application. This avoids prompting the user for authorization every
  # time the access token expires, by remembering the refresh token.
  # Note: FileStorage is not suitable for multi-user applications.
  file_storage = Google::APIClient::FileStorage.new(CREDENTIAL_STORE_FILE)
  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load
    # The InstalledAppFlow is a helper class to handle the OAuth 2.0 installed
    # application flow, which ties in with FileStorage to store credentials
    # between runs.
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => client_secrets.client_id,
      :client_secret => client_secrets.client_secret,
      :scope => ['https://www.googleapis.com/auth/adsense.readonly']
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end

  adsense = nil
  # Load cached discovered API, if it exists. This prevents retrieving the
  # discovery document on every run, saving a round-trip to the discovery
  # service.
  if File.exists? CACHED_API_FILE
    File.open(CACHED_API_FILE) do |file|
      adsense = Marshal.load(file)
    end
  else
    adsense = client.discovered_api('adsense', API_VERSION)
    File.open(CACHED_API_FILE, 'w') do |file|
      Marshal.dump(adsense, file)
    end
  end

  return client, adsense
end

# Generates a report for the default account.
def generate_report(client, adsense)
  result = client.execute(
      :api_method => adsense.reports.generate,
      :parameters => {'startDate' => '2011-01-01', 'endDate' => '2011-08-31',
                      'metric' => ['PAGE_VIEWS', 'AD_REQUESTS', 
                                   'AD_REQUESTS_COVERAGE',
                                   'CLICKS', 'AD_REQUESTS_CTR',
                                   'COST_PER_CLICK', 'AD_REQUESTS_RPM',
                                   'EARNINGS'],
                      'dimension' => ['DATE'],
                      'sort' => ['+DATE']})

  # Display headers.
  result.data.headers.each do |header|
    print '%25s' % header['name']
  end
  puts

  # Display results.
  result.data.rows.each do |row|
    row.each do |column|
      print '%25s' % column
    end
    puts
  end
end


if __FILE__ == $0
  client, adsense = setup()
  generate_report(client, adsense)
end
