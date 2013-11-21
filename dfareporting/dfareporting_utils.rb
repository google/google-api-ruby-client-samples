# Copyright (C) 2013 Google Inc.
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

require 'rubygems'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'logger'

API_VERSION = 'v1.3'
CACHED_API_FILE = "dfareporting-#{API_VERSION}.cache"
CREDENTIAL_STORE_FILE = "dfareporting-oauth2.json"

class DfaReportingUtils
  
  # Handles validating command line arguments and returning them as a Hash
  def self.get_arguments(argument_values, *argument_names)
    self.validate_arguments(argument_values, *argument_names)
    return self.generate_argument_map(argument_values, *argument_names)
  end
  
  # Validates the number of command line arguments matches what was expected
  def self.validate_arguments(argument_values, *argument_names)
    unless argument_values.length == argument_names.length
      # Format the arguments for display (ie, '<profile_id>')
      formatted_arguments = argument_names.map{|n| '<' + n + '>'}.join(' ')
      
      # Display a message to the user and exit  
      puts 'Usage: %s %s' % [$0, formatted_arguments]
      exit
    end
  end
  
  # Coverts parallel arrays of argument names and values into a single map
  def self.generate_argument_map(argument_values, *argument_names)
    ret = {}
    argument_names.each_with_index do |arg, index|
      ret[arg] = argument_values[index]
    end
    return ret
  end
  
  # Handles authentication and loading of the API.
  def self.setup()
    log_file = File.open('dfareporting.log', 'a+')
    log_file.sync = true
    logger = Logger.new(log_file)
    logger.level = Logger::DEBUG
  
    client = Google::APIClient.new(:application_name => 'Ruby DFA Reporting sample',
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
        :scope => ['https://www.googleapis.com/auth/dfareporting']
      )
      client.authorization = flow.authorize(file_storage)
    else
      client.authorization = file_storage.authorization
    end
  
    dfareporting = nil
    # Load cached discovered API, if it exists. This prevents retrieving the
    # discovery document on every run, saving a round-trip to the discovery
    # service.
    if File.exists? CACHED_API_FILE
      File.open(CACHED_API_FILE) do |file|
        dfareporting = Marshal.load(file)
      end
    else
      dfareporting = client.discovered_api('dfareporting', API_VERSION)
      File.open(CACHED_API_FILE, 'w') do |file|
        Marshal.dump(dfareporting, file)
      end
    end
  
    return client, dfareporting
  end
end