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

# This example illustrates how to list all values for a dimension
require './dfareporting_utils'

# Retrieve command line arguments
args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

client, dfareporting = DfaReportingUtils.setup()

# Create the dimension to query
dimension = {
  :dimensionName => 'dfa:advertiser',
  :startDate => '2013-01-01',
  :endDate => '2013-12-31'
}

# Get all dimension values
result = client.execute(
  :api_method => dfareporting.dimension_values.query,
  :body_object => dimension,
  :parameters => {
    :profileId => args['profile_id']
  })
      
while not result.nil? do
  # Display results.
  puts result.body
  
  token = result.data.next_page_token
  
  if token.nil? or token.empty? or token == '0'
    result = nil
  else
    result = client.execute(
      :api_method => dfareporting.dimension_values.query,
      :body_object => dimension,
      :parameters => {
        :profileId => args['profile_id']
      })
  end
end
