# This example illustrates how to get a user profile
require './dfareporting_utils'

args = DfaReportingUtils.get_arguments(ARGV, 'profile_id')

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get the user profile
result = client.execute(
    :api_method => dfareporting.user_profiles.get,
    :parameters => {
      :profileId => args['profile_id']
    })
        
# Display results.
puts result.body
