# This example illustrates how to update a report
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get the report
report = client.execute(
    :api_method => dfareporting.reports.get,
    :parameters => {
      :profileId => args['profile_id'],
      :reportId => args['report_id']
    })

# Update the report
report.data.name = 'Example Standard Report (Updated)'

result = client.execute(
    :api_method => dfareporting.reports.update,
    :body_object => report.data,
    :parameters => {
      :profileId => args['profile_id'],
      :reportId => args['report_id']
    })
      
# Display results.
puts result.body