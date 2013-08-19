require 'bundler/setup'
require 'sinatra/base'
require 'omniauth'
require 'google/omniauth'
require 'google/api_client/client_secrets'

CLIENT_SECRETS = Google::APIClient::ClientSecrets.load

class App < Sinatra::Base
  def client
    c = (Thread.current[:client] ||= 
        Google::APIClient.new(:application_name => 'Ruby Google+ sample',
                              :application_version => '1.0.0'))
    # It's really important to clear these out,
    # since we reuse client objects across requests
    # for caching and performance reasons.
    c.authorization.clear_credentials!
    return c
  end

  def plus_api; settings.plus; end

  configure do
    # Since we're saving the API definition to the settings, we're only
    # retrieving it once (on server start) and saving it between requests.
    # If this is still an issue, you could serialize the object and load it on
    # subsequent runs.
    plus = Google::APIClient.new.discovered_api('plus', 'v1')
    set :plus, plus
  end
  
  get '/' do
    erb :index
  end

  get '/whoami' do
    if session['credentials']
      # Build an authorization object from the client secrets.
      authorization = CLIENT_SECRETS.to_authorization
      authorization.update_token!(
        :access_token => session['credentials']['access_token'],
        :refresh_token => session['credentials']['refresh_token']
      )
      
      # Execute the profile API call.
      get_profile = lambda do
        client.execute(
          :api_method => plus_api.people.get,
          :parameters => {'userId' => 'me'},
          :authorization => authorization
        )
      end
      profile_result = get_profile.call()
      if profile_result.status == 401
        # The access token expired, fetch a new one and retry once.
        client.authorization.fetch_access_token!
        profile_result = get_profile.call()
      end

      # Execute the activities API call.
      get_activities = lambda do
        client.execute(
          :api_method => plus_api.activities.list,
          :parameters => {'userId' => 'me', 'collection' => 'public'},
          :authorization => authorization
        )
      end
      activities_result = get_activities.call()
      if activities_result.status == 401
        # The access token expired, fetch a new one and retry once.
        client.authorization.fetch_access_token!
        activities_result = get_activities.call()
      end
      
      erb :whoami, :locals => {
        :profile => profile_result.data,
        :post => activities_result.data.items.first
      }
    else
      content_type 'text/plain'
      "Missing credentials."
    end
  end

  # Support both GET and POST for callbacks.
  %w(get post).each do |method|
    send(method, "/auth/:provider/callback") do
      Thread.current[:client] = env['omniauth.auth']['extra']['client']
      
      # Keep track of the tokens. Use a real database in production.
      session['uid'] = env['omniauth.auth']['uid']
      session['credentials'] = env['omniauth.auth']['credentials']

      redirect '/whoami'      
    end
  end

  get '/auth/failure' do
    unless production?
      # Something went wrong. Dump the environment to help debug.
      # DO NOT DO THIS IN PRODUCTION.
      content_type 'application/json'
      MultiJson.encode(request.env)
    else
      content_type 'text/plain'
      "Something went wrong."
    end
  end
end

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider OmniAuth::Strategies::Google,
    CLIENT_SECRETS.client_id,
    CLIENT_SECRETS.client_secret,
    :scope => [
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/plus.me'
    ],
    :skip_info => false
end

run App.new
