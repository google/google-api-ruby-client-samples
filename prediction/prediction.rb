#!/usr/bin/ruby1.8
# -*- coding: utf-8 -*-

# Copyright:: Copyright 2011 Google Inc.
# License:: Apache 2.0
# Original Author:: Bob Aman, Winton Davies, Robert Kaplow
# Maintainer:: Robert Kaplow (mailto:rkaplow@google.com)

require 'rubygems'
require 'sinatra'
require 'google/api_client'

enable :sessions

# FILL IN THIS SECTION
# ------------------------
DATA_OBJECT = "BUCKET/OBJECT" # This is the {bucket}/{object} name you are using for the language file.
CLIENT_EMAIL = "YOUR_CLIENT_ID@developer.gserviceaccount.com" # Email of service account
KEYFILE = 'YOUR_KEY_FILE.p12' # Filename of the private key
PASSPHRASE = 'notasecret' # Passphrase for private key
PROJECT = 'YOUR_PROJECT_ID' # The id of your project
# ------------------------

configure do
  client = Google::APIClient.new(
    :application_name => 'Ruby Prediction sample',
    :application_version => '1.0.0')
  
  # Authorize service account
  key = Google::APIClient::PKCS12.load_key(KEYFILE, PASSPHRASE)
  asserter = Google::APIClient::JWTAsserter.new(
     CLIENT_EMAIL,
     ['https://www.googleapis.com/auth/prediction','https://www.googleapis.com/auth/devstorage.full_control'],
     key)
  client.authorization = asserter.authorize() 

  # Since we're saving the API definition to the settings, we're only retrieving
  # it once (on server start) and saving it between requests.
  # If this is still an issue, you could serialize the object and load it on
  # subsequent runs.
  prediction = client.discovered_api('prediction', 'v1.6')

  set :api_client, client
  set :prediction, prediction
end

def api_client; settings.api_client; end
def prediction; settings.prediction; end

get '/' do
  erb :index
end

get '/train' do
  training = prediction.trainedmodels.insert.request_schema.new
  training.id = 'language-sample'
  training.storage_data_location = DATA_OBJECT
  result = api_client.execute(
    :api_method => prediction.trainedmodels.insert,
    :headers => {'Content-Type' => 'application/json'},
    :body_object => training,
    :parameters => {'project' => PROJECT}
  )

  return [
    200,
    [["Content-Type", "application/json"]],
    ::JSON.generate({"status" => "success"})
  ]
end

get '/checkStatus' do
  result = api_client.execute(
    :api_method => prediction.trainedmodels.get,
    :parameters => {'id' => 'language-sample', 'project' => PROJECT}
  )

  return [
    200,
    [["Content-Type", "application/json"]],
    assemble_json_body(result)
  ]
end

post '/predict' do
  input = prediction.trainedmodels.predict.request_schema.new
  input.input = {}
  input.input.csv_instance = [params["input"]]
  result = api_client.execute(
    :api_method => prediction.trainedmodels.predict,
    :parameters => {'id' => 'language-sample', 'project' => PROJECT},
    :headers => {'Content-Type' => 'application/json'},
    :body_object => input
  )

  return [
    200,
    [["Content-Type", "application/json"]],
    assemble_json_body(result)
  ]
end

def assemble_json_body(result)
  # Assemble some JSON our client-side code can work with.
  json = {}
  if result.status != 200
    if result.data["error"]
      message = result.data["error"]["errors"].first["message"]
      json["message"] = "#{message} [#{result.status}]"
    else
      json["message"] = "Error. [#{result.status}]"
    end
    json["response"] = ::JSON.parse(result.body)
    json["status"] = "error"
  else
    json["response"] = ::JSON.parse(result.body)
    json["status"] = "success"
  end
  return ::JSON.generate(json)
end
