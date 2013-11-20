# This example illustrates how to delete a report.
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Delete the report
result = client.execute(
  :api_method => dfareporting.reports.delete,
  :parameters => {
    :profileId => args['profile_id'],
    :reportId => args['report_id']
  })
      
# Display results.
puts result.body