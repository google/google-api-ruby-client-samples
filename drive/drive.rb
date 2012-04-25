# Copyright (C) 2012 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'sinatra'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'logger'
require 'multi_json'
require 'data_mapper'

enable :sessions

SCOPES = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/userinfo.email'
]

##
# Datastore entity for storing OAuth 2.0 credentials.
class User
  include DataMapper::Resource
  property :id, Serial
  property :email, String, :length => 255
  property :refresh_token, String, :length => 255
end

##
# Set up
configure do
  db_url = Addressable::URI.parse(
    ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/user.db"
  )
  DataMapper.setup(:default, db_url)
  User.auto_migrate!

  # App identity
  set :credentials, Google::APIClient::ClientSecrets.load
  set :app_id, settings.credentials.client_id.sub(/[.-].*/,'')

  # Preload API definitions
  client = Google::APIClient.new
  set :drive, client.discovered_api('drive', 'v1')
  set :oauth2, client.discovered_api('oauth2', 'v2')
end

helpers do
  ##
  # Render json data in a response
  def json(data)
    content_type :json
    [200, data.to_json]
  end

  ##
  # Get an API client instance
  def api_client
    @client ||= (begin
      client = Google::APIClient.new

      client.authorization.client_id = settings.credentials.client_id
      client.authorization.client_secret = settings.credentials.client_secret
      client.authorization.redirect_uri =
        settings.credentials.redirect_uris.first
      client.authorization.scope = SCOPES
      client
    end)
  end

  def current_user
    if session[:user_id]
      @user ||= User.get(session[:user_id])
    end
  end

  def authorized?
    return (
      api_client.authorization.refresh_token &&
      api_client.authorization.access_token
    )
  end
end

before do
  # Make sure access token is up to date for each request
  api_client.authorization.update_token!(session)
  if api_client.authorization.refresh_token &&
      api_client.authorization.expired?
    api_client.authorization.fetch_access_token!
  end
end

after do
  # Serialize the access/refresh token to the session
  session[:access_token] = api_client.authorization.access_token
  session[:refresh_token] = api_client.authorization.refresh_token
  session[:expires_in] = api_client.authorization.expires_in
  session[:issued_at] = api_client.authorization.issued_at
end

##
# Upgrade our authorization code when a user launches the app from Drive &
# ensures saved refresh token is up to date
def authorize_code(authorization_code)
  api_client.authorization.code = authorization_code
  api_client.authorization.fetch_access_token!

  result = api_client.execute!(:api_method => settings.oauth2.userinfo.get)
  user = User.first_or_create(:email => result.data.email)
  api_client.authorization.refresh_token = (
    api_client.authorization.refresh_token || user.refresh_token
  )
  if user.refresh_token != api_client.authorization.refresh_token
    user.refresh_token = api_client.authorization.refresh_token
    user.save
  end
  session[:user_id] = user.id
end

def auth_url(state = '')
  user_email = current_user ? current_user.email : ''
  return api_client.authorization.authorization_uri(
    :state => state,
    :approval_prompt => :force,
    :access_type => :offline,
    :user_id => user_email
  ).to_s
end

##
# Prepare request data for upload
def prepare_data(body)
  data = MultiJson.decode(body)
  content = StringIO.new(data['content'])
  resource_id = data['resource_id']

  data.keep_if { |k,v| %w{title description mimeType}.include? k}
  file_content = Google::APIClient::UploadIO.new(content, data['mimeType'])

  [resource_id, data, file_content]
end

##
# Main entry point for the app. Ensures the user is authorized &
# inits the editor for either edit of the opened files or creating a new file.
get '/' do
  state = params[:state] || '{}'
  if params[:code]
    authorize_code(params[:code])
    redirect to("/?state=#{Addressable::URI.encode(state)}")
  elsif params[:error] # User denied the oauth grant
    halt 403
  end

  redirect auth_url(state) unless authorized?

  state = MultiJson.decode(state)
  @state = state
  @file_ids = (state['ids'] || [''])
  @app_id = settings.app_id
  erb :index
end

###
# Load content
#
get '/svc' do
  result = api_client.execute!(
    :api_method => settings.drive.files.get,
    :parameters => { 'id' => params['file_id'] })
  file = result.data.to_hash
  result = api_client.execute!(:uri => result.data.download_url)
  file['content'] = result.body
  json file
end

##
# Save a new file
post '/svc' do
  _, file, content = prepare_data(request.body)
  result = api_client.execute!(
    :api_method => settings.drive.files.insert,
    :body_object => file,
    :media => content,
    :parameters => {
      'uploadType' => 'multipart',
      'alt' => 'json'})
  json result.data.id
end

##
# Update existing file
put '/svc' do
  resource_id, file, content = prepare_data(request.body)
  result = api_client.execute!(
    :api_method => settings.drive.files.update,
    :body_object => file,
    :media => content,
    :parameters => {
      'id' => resource_id,
      'newRevision' => "true",
      'uploadType' => 'multipart',
      'alt' => 'json'})
  json result.data.id
end

##
# For /svc methods, assume client errors are due to auth failures
# and return a redirect (via JSON)
error Google::APIClient::ClientError do
  response = {
    'redirect' => auth_url('{}')
  }
  json response
end

##
# Oh noes!
error Google::APIClient::ServerError do
  halt 500
end
