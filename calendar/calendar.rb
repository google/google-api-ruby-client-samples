require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'google/api_client'
require 'logger'

enable :sessions

# Set up our token store
DataMapper.setup(:default, 'sqlite::memory:')
class TokenPair
  include DataMapper::Resource

  property :id, Serial
  property :refresh_token, String, :length => 255
  property :access_token, String, :length => 255
  property :expires_in, Integer
  property :issued_at, Integer

  def update_token!(object)
    self.refresh_token = object.refresh_token
    self.access_token = object.access_token
    self.expires_in = object.expires_in
    self.issued_at = object.issued_at
  end

  def to_hash
    return {
      :refresh_token => refresh_token,
      :access_token => access_token,
      :expires_in => expires_in,
      :issued_at => Time.at(issued_at)
    }
  end
end
TokenPair.auto_migrate!

configure do
  log_file = File.open('calendar.log', 'a+')
  log_file.sync = true
  logger = Logger.new(log_file)
  logger.level = Logger::DEBUG
  set :logger, logger
end

def logger; settings.logger; end

before do
  @client = Google::APIClient.new
  @client.authorization.client_id = ''
  @client.authorization.client_secret = ''
  @client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
  @client.authorization.redirect_uri = to('/oauth2callback')
  @client.authorization.code = params[:code] if params[:code]
  logger.debug session.inspect
  if session[:token_id]
    # Load the access token here if it's available
    token_pair = TokenPair.get(session[:token_id])
    @client.authorization.update_token!(token_pair.to_hash)
  end
  if @client.authorization.refresh_token && @client.authorization.expired?
    @client.authorization.fetch_access_token!
  end
  @calendar = @client.discovered_api('calendar', 'v3')
  unless @client.authorization.access_token || request.path_info =~ /^\/oauth2/
    redirect to('/oauth2authorize')
  end
end

get '/oauth2authorize' do
  redirect @client.authorization.authorization_uri.to_s, 303
end

get '/oauth2callback' do
  @client.authorization.fetch_access_token!
  # Persist the token here
  token_pair = if session[:token_id]
    TokenPair.get(session[:token_id])
  else
    TokenPair.new
  end
  token_pair.update_token!(@client.authorization)
  token_pair.save
  session[:token_id] = token_pair.id
  redirect to('/')
end

get '/' do
  result = @client.execute(:api_method => @calendar.events.list,
                           :parameters => {'calendarId' => 'primary'})
  status, _, _ = result.response
  [status, {'Content-Type' => 'application/json'}, result.data.to_json]
end
