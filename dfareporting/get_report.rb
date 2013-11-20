# This example illustrates how to get a report.
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

client, dfareporting = DfaReportingUtils.setup()

# Get the report
result = client.execute(
    :api_method => dfareporting.reports.get,
    :parameters => {
      :profileId => args['profile_id'],
      :reportId => args['report_id']
    })

# Display results.
puts result.body