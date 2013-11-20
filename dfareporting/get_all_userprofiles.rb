# This example illustrates how to list all user profiles
require './dfareporting_utils'

# Authenticate
client, dfareporting = DfaReportingUtils.setup()

# Get all user profiles
result = client.execute(
    :api_method => dfareporting.user_profiles.list)  
        
# Display results.
puts result.body
