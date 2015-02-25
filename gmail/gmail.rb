require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'sinatra'
require 'logger'

enable :sessions

CREDENTIAL_STORE_FILE = "gmail-oauth2.json"

def logger; settings.logger end

def api_client; settings.api_client; end

def gmail_api; settings.gmail; end

configure do
  log_file = File.open('gmail.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG

  client = Google::APIClient.new(
    :application_name => 'Ruby Gmail sample',
    :application_version => '1.0.0')

  gmail = client.discovered_api('gmail', 'v1')

  set :logger, logger
  set :api_client, client
  set :gmail, gmail
end

before do
  # Ensure user has authorized the app
  # redirect user_credentials.authorization_uri.to_s, 303
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
      :scope => ['https://www.googleapis.com/auth/gmail.readonly']
    )
    api_client.authorization = flow.authorize(file_storage)
  else
    api_client.authorization = file_storage.authorization
  end
end

get '/' do
  # Fetch list of emails on the user's gmail
  @result = api_client.execute(
    api_method: gmail_api.users.messages.list,
    parameters: {
        userId: "leckylao@gmail.com",
    },
    headers: {'Content-Type' => 'application/json'})
  erb :index
end
