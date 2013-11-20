# This example illustrates how to create a report
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Create a new report resource to insert
report = {
  :name => 'Example Standard Report',
  :type => 'STANDARD',
  :criteria => {
    :dateRange => {:relativeDateRange => 'YESTERDAY'},
    :dimensions => [{:name => 'dfa:campaign'}],
    :metricNames => ['dfa:clicks']
  }
}

# Insert the report
result = client.execute(
  :api_method => dfareporting.reports.insert,
  :body_object => report,
  :parameters => {
    :profileId => args['profile_id']
  })
      
# Display results.
puts result.body