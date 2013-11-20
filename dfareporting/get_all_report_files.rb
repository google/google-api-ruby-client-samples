# This example illustrates how to list all files for a report
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get all report files
result = client.execute(
  :api_method => dfareporting.reports.files.list,
  :parameters => {
    :profileId => args['profile_id'],
    :reportId => args['report_id']
  })
      
while not result.nil? do
  # Display results.
  puts result.body
  
  token = result.data.next_page_token
    
  if token.nil? or token.empty?
    result = nil
  else
    result = client.execute(
        :api_method => dfareporting.reports.files.list,
        :parameters => {
          :profileId => args['profile_id'],
          :reportId => args['report_id'],
          :pageToken => result.data.nextPageToken
        })
  end
end
