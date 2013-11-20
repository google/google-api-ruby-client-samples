# This example illustrates how to get a report file.
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id', 'report_id',
  'file_id')

client, dfareporting = DfaReportingUtils.setup()

# Get the report
result = client.execute(
    :api_method => dfareporting.reports.files.get,
    :parameters => {
      :profileId => args['profile_id'],
      :reportId => args['report_id'],
      :fileId => args['file_id']
    })

# Display results.
puts result.body