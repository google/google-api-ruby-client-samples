# This example illustrates how to patch a report
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Create a report resource with the fields to patch
report = {
  :criteria => {
    :dateRange => {:relativeDateRange => 'YESTERDAY'}
  }
}

# Patch the report
result = client.execute(
  :api_method => dfareporting.reports.patch,
  :body_object => report,
  :parameters => {
    :profileId => args['profile_id'],
    :reportId => args['report_id']
})
      
# Display results.
puts result.body