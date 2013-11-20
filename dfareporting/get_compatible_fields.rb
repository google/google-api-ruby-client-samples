# This example illustrates how to get the compatible fields for a report.
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id')

client, dfareporting = DfaReportingUtils.setup()

# Get the report
report = client.execute(
    :api_method => dfareporting.reports.get,
    :parameters => {
      :profileId => args['profile_id'],
      :reportId => args['report_id']
    })
    
# Get the compatible fields
result = client.execute(
    :api_method => dfareporting.reports.compatible_fields.query,
    :body_object => report.data.to_hash,
    :parameters => {
      :profileId => args['profile_id']
    }) 

# Display results.
puts result.body