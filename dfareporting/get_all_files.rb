# This example illustrates how to list all files for a profile
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get all files 
result = client.execute(
  :api_method => dfareporting.files.list,
  :parameters => {:profileId => args['profile_id']})    
      
while not result.nil? do
  # Display results.
  puts result.body
  
  token = result.data.next_page_token
  
  if token.nil? or token.empty?
    result = nil
  else
    result = client.execute(
      :api_method => dfareporting.files.list,
      :parameters => {
        :profileId => args['profile_id'],
        :pageToken => result.data.nextPageToken
      })
  end
end
