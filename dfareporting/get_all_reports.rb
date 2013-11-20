# This example illustrates how to list all reports for a profile
require './dfareporting_utils'

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
