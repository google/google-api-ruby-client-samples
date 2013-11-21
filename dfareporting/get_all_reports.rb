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

# This example illustrates how to list all reports for a profile
require './dfareporting_utils'

# Retrieve command line arguments
args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get all reports
result = client.execute(
    :api_method => dfareporting.reports.list,
    :parameters => {:profileId => args['profile_id']})    
      
while not result.nil? do
  # Display results.
  puts result.body

  token = result.data.next_page_token
    
  if token.nil? or token.empty?
    result = nil
  else
    result = client.execute(
        :api_method => dfareporting.reports.list,
        :parameters => {
          :profileId => args['profile_id'],
          :pageToken=> result.data.nextPageToken
        })
  end
end
